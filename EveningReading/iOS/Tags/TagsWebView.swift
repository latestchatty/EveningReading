//
//  TagsWebView2.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 6/4/21.
//

import Foundation
import SwiftUI
import Combine
import WebKit
import UIKit

struct TagsWebView: UIViewRepresentable {
    @Binding var webViewLoading: Bool
    @Binding var webViewProgress: Double
    @Binding var goToPostId: Int
    @Binding var showingPost: Bool
    var webView: WKWebView?

    init(webViewLoading: Binding<Bool>, webViewProgress: Binding<Double>, goToPostId: Binding<Int>, showingPost: Binding<Bool>) {
        let processPool = WKProcessPool()
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        configuration.processPool = processPool
        self.webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        
        self._webViewLoading = webViewLoading
        self._webViewProgress = webViewProgress
        self._goToPostId = goToPostId
        self._showingPost = showingPost
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: TagsWebView

        init(_ parent: TagsWebView) {
            self.parent = parent
        }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            switch navigationAction.navigationType {
            case .linkActivated:
                if let url = navigationAction.request.url {
                    if url.absoluteString.contains("chatty?id") {
                        // Open natively
                        let postId = url.absoluteString.replacingOccurrences(of: "https://www.shacknews.com/chatty?id=", with: "")
                        if postId.isInt {
                            parent.goToPostId = Int(postId) ?? 0
                            parent.showingPost = true
                            decisionHandler(.cancel)
                        } else {
                            decisionHandler(.allow)
                        }
                        /*
                        // Open in Safari
                        let shared = UIApplication.shared
                        if shared.canOpenURL(url) {
                            shared.open(url, options: [:], completionHandler: nil)
                        }
                        decisionHandler(.cancel)
                        */
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

        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            //
        }
        
        func addProgressObserver() {
            parent.webView?.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if let o = object as? WKWebView, o == parent.webView {
                if keyPath == #keyPath(WKWebView.estimatedProgress) {
                    parent.webViewProgress = parent.webView?.estimatedProgress ?? 0
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView  {
        let tagsUrl = "https://www.shacknews.com/tags-user"
        let username: String = KeychainWrapper.standard.string(forKey: "Username") ?? ""
        let password: String = KeychainWrapper.standard.string(forKey: "Password") ?? ""
        
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
                                self.webViewLoading = false
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
        
        return webView!
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.navigationDelegate = context.coordinator
        uiView.uiDelegate = context.coordinator
    }
}
