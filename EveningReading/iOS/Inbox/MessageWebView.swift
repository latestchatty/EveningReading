//
//  MessageWebView.swift
//  iOS
//
//  Created by Chris Hodge on 9/3/20.
//

import Foundation
import SwiftUI
import WebKit
import Combine

class MessageWebViewModel: ObservableObject {
    @Published var body: String
    @Published var colorScheme: ColorScheme
    @Published var didFinishLoading: Bool = false
    @Published var didContentSizeChange: Bool = false

    init (body: String, colorScheme: ColorScheme) {
        self.body = body
        self.colorScheme = colorScheme
    }
}

struct MessageWebView: UIViewRepresentable {
    @ObservedObject var viewModel: MessageWebViewModel
    @Binding var hyperlinkUrl: String?
    @Binding var showingWebView: Bool
    @Binding var dynamicHeight: CGFloat
    @Binding var templateA: String
    @Binding var templateB: String

    let webView = WKWebView()
    
    func makeUIView(context: UIViewRepresentableContext<MessageWebView>) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        loadMessageHtml()
        return self.webView
    }
    
    func loadMessageHtml() {
        if self.viewModel.body != "" {
            self.webView.isOpaque = false
            self.webView.backgroundColor = UIColor.clear
            self.webView.scrollView.backgroundColor = UIColor.clear
            
            self.webView.loadHTMLString(self.templateA + self.viewModel.body + self.templateB, baseURL: nil)
        }
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<MessageWebView>) {
        return
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: MessageWebViewModel
        var parent: MessageWebView
        
        init(_ viewModel: MessageWebViewModel, _ parent: MessageWebView) {
            self.viewModel = viewModel
            self.parent = parent
            
            // if dynamic type font size changes...
            super.init()
            NotificationCenter.default.addObserver(self,
              selector: #selector(contentSizeDidChange(_:)),
              name: UIContentSizeCategory.didChangeNotification,
              object: nil)
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.viewModel.didFinishLoading = true
            
            if self.parent.dynamicHeight > 0.0 && !self.viewModel.didContentSizeChange {
                return
            }
            
            self.parent.webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
                    if complete != nil {
                        self.parent.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                            self.parent.dynamicHeight = (height as! CGFloat)
                            webView.bounds.size.height = (height as! CGFloat)
                            
                            self.viewModel.didContentSizeChange = false
                        })
                    }
            })
        }
                
        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated {
                guard let url = navigationAction.request.url else {
                    decisionHandler(.allow)
                    return
                }
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                if components?.scheme == "http" || components?.scheme == "https"
                {
                    parent.hyperlinkUrl = url.description
                    parent.showingWebView = true
                    decisionHandler(.cancel)
                } else {
                    decisionHandler(.allow)
                }
            } else {
                decisionHandler(.allow)
            }
        }
        
        // if dynamic type font size changes
        @objc private func contentSizeDidChange(_ notification: Notification) {
            self.viewModel.didContentSizeChange = true
            
            self.parent.webView.reload()
            self.parent.loadMessageHtml()
            
            self.parent.webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
                    if complete != nil {
                        self.parent.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                            self.parent.dynamicHeight = (height as! CGFloat)
                            self.parent.webView.bounds.size.height = (height as! CGFloat)
                        })
                    }
            })
        }
    }

    func makeCoordinator() -> MessageWebView.Coordinator {
        Coordinator(viewModel, self)
    }
}
