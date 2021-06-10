//
//  macOSTagsWebView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/10/21.
//

import SwiftUI
import WebKit
import Combine

struct macOSTagsWebView: NSViewRepresentable {
    @Binding var webViewLoading: Bool
    @Binding var webViewProgress: Double
    @Binding var goToPostId: Int
    @Binding var showingPost: Bool
    @Binding var username: String
    @Binding var password: String
    
    var webView: WKWebView?
    
    init(webViewLoading: Binding<Bool>, webViewProgress: Binding<Double>, goToPostId: Binding<Int>, showingPost: Binding<Bool>, username: Binding<String>, password: Binding<String>) {
        let processPool = WKProcessPool()
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        configuration.processPool = processPool
        self.webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        
        self._webViewLoading = webViewLoading
        self._webViewProgress = webViewProgress
        self._goToPostId = goToPostId
        self._showingPost = showingPost
        self._username = username
        self._password = password
    }
    
    public func makeNSView(context: NSViewRepresentableContext<macOSTagsWebView>) -> WKWebView {
        let tagsUrl = "https://www.shacknews.com/tags-user"
        
        self.webView?.navigationDelegate = context.coordinator
        self.webView?.uiDelegate = context.coordinator as? WKUIDelegate
        
        let processPool = WKProcessPool()
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        configuration.processPool = processPool
        
        context.coordinator.addProgressObserver()
        
        if username != "" && password != "" {
                    
            DispatchQueue.main.async {
                let req = URLRequest(url: URL(string: tagsUrl)!)
                
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
                        
                        self.webView?.configuration.websiteDataStore.httpCookieStore.setCookie(cookieLI) {
                            self.webView?.configuration.websiteDataStore.httpCookieStore.setCookie(cookieINT) {
                                var cookieLength = 0
                                self.webView?.configuration.websiteDataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
                                    for record in records {
                                        cookieLength += record.displayName.count
                                    }
                                }
                                
                                self.webView?.load(req)
                            }
                        }
                        
                        
                    }
                })
                task.resume()
            }
            
            return webView!
        }
        
        DispatchQueue.main.async {
            let url = URL(string: tagsUrl)!
            let request = URLRequest(url: url)
            self.webView?.load(request)
            self.webViewLoading = false
        }
        
        return self.webView ?? WKWebView(frame: CGRect.zero, configuration: configuration)
    }

    public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<macOSTagsWebView>) { }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: macOSTagsWebView

        init(_ parent: macOSTagsWebView) {
            self.parent = parent
        }
        
        func addProgressObserver() {
            parent.webView?.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if let o = object as? WKWebView, o == parent.webView {
                if keyPath == #keyPath(WKWebView.estimatedProgress) {
                    let progress = parent.webView?.estimatedProgress ?? 0.25
                    parent.webViewProgress = progress > 0.25 ? progress : 0.25
                    if progress == 1.0 {
                        parent.webViewLoading = false
                    }
                }
            }
        }
        
        public func webView(_: WKWebView, didFail: WKNavigation!, withError: Error) { }

        public func webView(_: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) { }

        public func webView(_ web: WKWebView, didFinish: WKNavigation!) { }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            switch navigationAction.navigationType {
            case .linkActivated:
                if let url = navigationAction.request.url {
                    if url.absoluteString.contains("chatty?id") {
                        // Open in Safari
                        NSWorkspace.shared.open(url)
                        decisionHandler(.cancel)
                    } else {
                        decisionHandler(.allow)
                    }
                } else {
                    decisionHandler(.allow)
                }
            default:
                decisionHandler(.allow)
            }
        }

    }

}
