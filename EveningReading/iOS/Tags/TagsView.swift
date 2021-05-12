//
//  TagsView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct TagsView: View {
    @ObservedObject var tagsWebViewStore = TagsWebViewStore()
    @State private var webViewProgress: Double = 0
    @State private var webViewLoading: Bool = true
    @State private var hyperlinkUrl: String = "about:blank"
    
    func goBack() {
        tagsWebViewStore.webView.goBack()
    }

    func goForward() {
        tagsWebViewStore.webView.goForward()
    }

    var body: some View {
        VStack {
            GoToPostView()
            if self.webViewLoading {
                ProgressView(value: self.webViewProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(UIColor.systemBlue)))
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            }
            TagsWebView(webView: self.tagsWebViewStore.webView, viewModel: self.tagsWebViewStore, estimatedProgress: self.$webViewProgress, isLoading: self.$webViewLoading, loadUrl: self.$hyperlinkUrl)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                let user: String? = KeychainWrapper.standard.string(forKey: "Username")
                let pass: String? = KeychainWrapper.standard.string(forKey: "Password")
                self.tagsWebViewStore.loadUrlWithShackAuth(urlStr: "https://www.shacknews.com/tags-user", username: user ?? "", password: pass ?? "")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                let user: String? = KeychainWrapper.standard.string(forKey: "Username")
                let pass: String? = KeychainWrapper.standard.string(forKey: "Password")
                self.tagsWebViewStore.loadUrlWithShackAuth(urlStr: "https://www.shacknews.com/tags-user", username: user ?? "", password: pass ?? "")
            }
        }
        .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Tags", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 26, height: 16))
    }
}

struct TagsView_Previews: PreviewProvider {
    static var previews: some View {
        TagsView()
    }
}
