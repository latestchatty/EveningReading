//
//  PostWebView.swift
//  iOS
//
//  Created by Chris Hodge on 7/21/20.
//

import Foundation
import SwiftUI
import WebKit
import Combine

class PostWebViewModel: ObservableObject {
    @Published var body: String
    @Published var colorScheme: ColorScheme
    @Published var didContentSizeChange: Bool = false

    init (body: String, colorScheme: ColorScheme) {
        self.body = body
        self.colorScheme = colorScheme
    }
}

class PostWKWebView {
    static let sharedInstance = PostWKWebView()
    let webView: WKWebView // = WKWebView()
    
    let webViewProcessPool: WKProcessPool = WKProcessPool()
    let webViewConfig: WKWebViewConfiguration = WKWebViewConfiguration()
       
    init() {
        self.webViewConfig.processPool = self.webViewProcessPool
        self.webView = WKWebView(frame: .zero, configuration: self.webViewConfig)
        
        self.webView.allowsLinkPreview = false
        self.webView.isOpaque = false
        self.webView.backgroundColor = UIColor.clear
        self.webView.scrollView.backgroundColor = UIColor.clear
        self.webView.scrollView.isScrollEnabled = true
    }
}

struct PostWebView: UIViewRepresentable {
    @ObservedObject var viewModel: PostWebViewModel
    @Binding var dynamicHeight: CGFloat
    @Binding var templateA: String
    @Binding var templateB: String

    let webView = PostWKWebView.sharedInstance.webView
    
    func makeUIView(context: UIViewRepresentableContext<PostWebView>) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        loadPostHtml()
        return self.webView
    }
    
    func getTemplate() -> String {
        return self.templateA
    }
    
    func loadPostHtml() {
        if self.viewModel.body != "" {
            self.webView.loadHTMLString(getTemplate() + self.viewModel.body + self.templateB, baseURL: URL(string: "https://www.shacknews.com"))
        }
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<PostWebView>) {
        return
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: PostWebViewModel
        var parent: PostWebView
        
        init(_ viewModel: PostWebViewModel, _ parent: PostWebView) {
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
            //print("didCommit")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            //debugPrint("didFail")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.parent.webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
                    if complete != nil {
                        self.parent.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                            //print("PostWebView Height - \(height as! CGFloat)")
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
            self.parent.loadPostHtml()
            
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

    func makeCoordinator() -> PostWebView.Coordinator {
        Coordinator(viewModel, self)
    }
}
