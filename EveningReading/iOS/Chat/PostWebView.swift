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
    @Published var author: String
    @Published var body: String
    @Published var colorScheme: ColorScheme
    @Published var didContentSizeChange: Bool = false

    init (author: String, body: String, colorScheme: ColorScheme) {
        self.author = author
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

    let webView = PostWKWebView.sharedInstance.webView
    
    func makeUIView(context: UIViewRepresentableContext<PostWebView>) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        loadPostHtml()
        return self.webView
    }
        
    func loadPostHtml() {
        if self.viewModel.body != "" {
            
            var preHtml = "<html><head><meta content='text/html; charset=utf-8' http-equiv='content-type'><meta content='initial-scale=1.0; maximum-scale=1.0; user-scalable=0;' name='viewport'><style>"
            let postHtml = "</body></html>"
            
            if let filepath = Bundle.main.path(forResource: "Stylesheet", ofType: "css") {
                do {
                    let postTemplate = try String(contentsOfFile: filepath)
                    let postTemplateStyled = postTemplate
                        .replacingOccurrences(of: "<%= linkColorLight %>", with: UIColor.black.toHexString())
                        .replacingOccurrences(of: "<%= linkColorDark %>", with: UIColor.systemTeal.toHexString())
                        .replacingOccurrences(of: "<%= jtSpoilerDark %>", with: "#21252b")
                        .replacingOccurrences(of: "<%= jtSpoilerLight %>", with: "#8e8e93")
                        .replacingOccurrences(of: "<%= jtOliveDark %>", with: UIColor(Color("OliveText")).toHexString())
                        .replacingOccurrences(of: "<%= jtOliveLight %>", with: "#808000")
                        .replacingOccurrences(of: "<%= jtLimeLight %>", with: "#A2D900")
                        .replacingOccurrences(of: "<%= jtLimeDark %>", with: "#BFFF00")
                        .replacingOccurrences(of: "<%= jtPink %>", with: UIColor(Color("PinkText")).toHexString())
                    preHtml += postTemplateStyled + "</style>"
                } catch {
                    preHtml += "</style>"
                }
            } else {
                preHtml += "</style>"
            }
            
            if self.viewModel.author != "" {
                preHtml += "<div class='post_author'>" + self.viewModel.author + "</div><br>"
            }
            
            self.webView.loadHTMLString(preHtml + self.viewModel.body + postHtml, baseURL: URL(string: "https://www.shacknews.com"))
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
            
            // If dynamic type font size changes...
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
