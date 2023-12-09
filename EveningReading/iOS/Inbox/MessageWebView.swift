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
            
            var preMessageBody = "<html><head><meta content='text/html; charset=utf-8' http-equiv='content-type'><meta content='initial-scale=1.0; maximum-scale=1.0; user-scalable=0;' name='viewport'><style>"
            let postMessageBody = "</body></html>"
            
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
                    preMessageBody += postTemplateStyled + "</style>"
                } catch {
                    preMessageBody += "</style>"
                }
            } else {
                preMessageBody += "</style>"
            }
            
            self.webView.loadHTMLString(preMessageBody + self.viewModel.body + postMessageBody, baseURL: nil)
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
