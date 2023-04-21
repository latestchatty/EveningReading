//
//  macOSLinkViewer.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 4/21/23.
//

// https://stackoverflow.com/questions/62962063/implement-webkit-with-swiftui-on-macos-and-create-a-preview-of-a-webpage

import SwiftUI
import Combine
import WebKit

struct macOSLinkViewerSheet: View {
    @ObservedObject var model: macOSLinkViewerViewModel
    init(mesgURL: String) {
        self.model = macOSLinkViewerViewModel(link: mesgURL)
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Spacer()
                Spacer()
                Text(self.model.didFinishLoading ? self.model.pageTitle : "")
                Spacer()
                Button(action: {
                    if let url = URL(string: self.model.link) {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("Open with Safari")
                }
                .padding(.vertical)
            }
            macOSLinkViewer(viewModel: model)
        }
        .frame(width: 800, height: 450, alignment: .bottom)
        .padding(5.0)
    }
}

class macOSLinkViewerViewModel: ObservableObject {
    @Published var link: String
    @Published var didFinishLoading: Bool = false
    @Published var pageTitle: String
    
    init (link: String) {
        self.link = link
        self.pageTitle = ""
    }
}

struct macOSLinkViewer: NSViewRepresentable {
    public typealias NSViewType = WKWebView
    @ObservedObject var viewModel: macOSLinkViewerViewModel

    private let webView: WKWebView = WKWebView()
    public func makeNSView(context: NSViewRepresentableContext<macOSLinkViewer>) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator as? WKUIDelegate
        webView.load(URLRequest(url: URL(string: viewModel.link)!))
        return webView
    }

    public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<macOSLinkViewer>) { }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: macOSLinkViewerViewModel

        init(_ viewModel: macOSLinkViewerViewModel) {
           self.viewModel = viewModel
        }
        
        public func webView(_: WKWebView, didFail: WKNavigation!, withError: Error) { }

        public func webView(_: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) { }

        public func webView(_ web: WKWebView, didFinish: WKNavigation!) {
            self.viewModel.pageTitle = web.title!
            self.viewModel.link = web.url?.absoluteString as! String
            self.viewModel.didFinishLoading = true
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
    }
}
