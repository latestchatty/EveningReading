//
//  TagsWebView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/8/21.
//

import SwiftUI
import Combine
import WebKit
import os

public class TagsWebViewStore: ObservableObject {
    @Published public var webView: WKWebView {
        didSet {
            setupObservers()
        }
    }
    @Published var contentHeight: CGFloat

    public init(webView: WKWebView = WKWebView(), contentHeight: CGFloat = 288.0) {
        self.webView = webView
        self.contentHeight = contentHeight
        setupObservers()
    }
  
    private func setupObservers() {
        func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> NSKeyValueObservation {
            return webView.observe(keyPath, options: [.prior]) { _, change in
                if change.isPrior {
                    self.objectWillChange.send()
                }
            }
        }
        
        observers = [
            subscriber(for: \.title),
            subscriber(for: \.url),
            subscriber(for: \.isLoading),
            subscriber(for: \.estimatedProgress),
            subscriber(for: \.hasOnlySecureContent),
            subscriber(for: \.serverTrust),
            subscriber(for: \.canGoBack),
            subscriber(for: \.canGoForward)
        ]
    }
    
    public func loadUrlWithShackAuth(urlStr: String, username: String, password: String) {
                
        if username == "" || password == "" {
            self.webView = WKWebView(frame: CGRect.zero)
            let req = URLRequest(url: URL(string: urlStr)!)
            self.webView.load(req)
            return
        }
        
        DispatchQueue.main.async {
            let processPool = WKProcessPool()
            let configuration = WKWebViewConfiguration()
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
            configuration.processPool = processPool
            self.webView = WKWebView(frame: CGRect.zero, configuration: configuration)
            
            let req = URLRequest(url: URL(string: urlStr)!)
            
            var liCookie = ""
            var intCookie = ""
            let newPostUrl = URL(string: "https://www.shacknews.com/account/signin")!
            var components = URLComponents(url: newPostUrl, resolvingAgainstBaseURL: false)!
            components.queryItems = [
                URLQueryItem(name: "user-identifier", value: username),
                URLQueryItem(name: "supplied-pass", value: password)
            ]
            let query = components.url!.query

            var cookieRequest = URLRequest(url: newPostUrl)
            cookieRequest.httpMethod = "POST"
            cookieRequest.httpBody = Data(query!.utf8)

            let session = URLSession.shared
            let task = session.dataTask(with: cookieRequest as URLRequest, completionHandler: { data, response, error in
                guard error == nil else {
                    return
                }
                guard let _ = data else {
                    return
                }
                
                let cookieName = "_shack_li_"
                if let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName }) {
                    liCookie = cookie.value
                }
                let cookieName2 = "_shack_int_"
                if let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName2 }) {
                    intCookie = cookie.value
                }
                
                DispatchQueue.main.async {
                    let cookieLI = HTTPCookie(properties: [
                        .domain: "www.shacknews.com",
                        .path: "/",
                        .name: "_shack_li_",
                        .value: liCookie,
                        .secure: "TRUE",
                        .expires: NSDate(timeIntervalSinceNow: 31556926)
                    ])!
                    let cookieINT = HTTPCookie(properties: [
                        .domain: "www.shacknews.com",
                        .path: "/",
                        .name: "_shack_int_",
                        .value: intCookie,
                        .secure: "TRUE",
                        .expires: NSDate(timeIntervalSinceNow: 604800)
                    ])!
                    
                    /*
                    let task = URLSession.shared.dataTask(with: URL(string: urlStr)!) { data, response, error in
                        if let error = error {
                            print("TagsWebView error")
                            return
                        }
                        guard let httpResponse = response as? HTTPURLResponse,
                            (200...299).contains(httpResponse.statusCode) else {
                            print("TagsWebView server error")
                            return
                        }
                        if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                            let data = data,
                            let string = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                let removedTargets = string.replacingOccurrences(of: #"target="_blank""#, with: "")
                                self.webView.loadHTMLString(removedTargets, baseURL: URL(string: "https://www.shacknews.com"))
                            }
                        }
                    }
                    task.resume()
                    */
                    
                    
                    self.webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookieLI) {
                        self.webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookieINT) {
                            var cookieLength = 0
                            self.webView.configuration.websiteDataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
                                for record in records {
                                    cookieLength += record.displayName.count
                                }
                            }
                            
                            self.webView.load(req)
                        }
                    }
                    
                    
                }
            })
            task.resume()
        }
    }
  
    private var observers: [NSKeyValueObservation] = []
  
    deinit {
        observers.forEach {
            $0.invalidate()
        }
    }
}

public struct TagsWebView: View, UIViewRepresentable {
    public let webView: WKWebView
    
    private var viewModel: TagsWebViewStore
    @Binding var estimatedProgress: Double
    @Binding var isLoading: Bool
    @Binding var loadUrl: String

    public typealias UIViewType = TagViewContainerView<WKWebView>
  
    public init(webView: WKWebView, viewModel: TagsWebViewStore, estimatedProgress: Binding<Double>, isLoading: Binding<Bool>, loadUrl: Binding<String>) {
        self.webView = webView
        self.viewModel = TagsWebViewStore()
        self._estimatedProgress = estimatedProgress
        self._isLoading = isLoading
        self._loadUrl = loadUrl
    }
  
    public func makeUIView(context: UIViewRepresentableContext<TagsWebView>) -> TagsWebView.UIViewType {
        self.webView.navigationDelegate = context.coordinator
        return TagViewContainerView()
    }
  
    public func updateUIView(_ uiView: TagsWebView.UIViewType, context: UIViewRepresentableContext<TagsWebView>) {
        
        if uiView.contentView !== webView {
            DispatchQueue.main.async {
                uiView.contentView = webView
                uiView.contentView?.navigationDelegate = context.coordinator
            }
        }
        
        /*
        if webView.url?.description == "about:blank" {
            let req = URLRequest(url: URL(string: loadUrl)!)
            webView.load(req)
        }
        */
        
        if self.webView.estimatedProgress >= 1.0 {
            DispatchQueue.main.async {
                self.estimatedProgress = 1.0
            }
        } else {
            DispatchQueue.main.async {
                self.estimatedProgress = self.webView.estimatedProgress
            }
        }
        
        if !self.webView.isLoading {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                self.isLoading = false
            }
        } else {
            DispatchQueue.main.async {
                self.isLoading = true
            }
        }
        
    }
    
    public func makeCoordinator() -> TagsWebView.Coordinator {
        Coordinator(self)
    }
  
    public class Coordinator: NSObject, WKNavigationDelegate {
        var parent: TagsWebView
    
        init(_ parent: TagsWebView) {
            self.parent = parent
        }
    
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
        }
        
        private func webViewWebContentProcessDidTerminate() {
            
        }
        
        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            switch navigationAction.navigationType {
            case .linkActivated:
                print("linkActivated")
                if let url = navigationAction.request.url {
                    if url.absoluteString.contains("chatty?id") {
                        let shared = UIApplication.shared
                        if shared.canOpenURL(url) {
                            shared.open(url, options: [:], completionHandler: nil)
                        }
                        decisionHandler(.cancel)
                    } else {
                        decisionHandler(.allow)
                    }
                } else {
                    decisionHandler(.allow)
                }
            default:
                print("otherAction")
                decisionHandler(.allow)
            }
        }
        
    }
}

public class TagViewContainerView<ContentView: UIView>: UIView {
    var contentView: ContentView? {
        willSet {
            contentView?.removeFromSuperview()
        }
        didSet {
            if let contentView = contentView {
                addSubview(contentView)
                contentView.backgroundColor = UIColor.systemBackground
                contentView.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    contentView.topAnchor.constraint(equalTo: topAnchor),
                    contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
            }
        }
    }
}
