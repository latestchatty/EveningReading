//
//  TagsView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct TagsView: View {
    @State private var webViewLoading: Bool = true
    @State private var webViewProgress: Double = 0.25
    @State private var goToPostId: Int = 0
    @State private var showingPost: Bool = false
    
    var body: some View {
        VStack {
            if self.webViewLoading {
                ProgressView(value: self.webViewProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(UIColor.systemBlue)))
                    .frame(maxWidth: .infinity)
            }
            
            NavigationLink(destination: ThreadDetailView(threadId: .constant(0), postId: self.$goToPostId, replyCount: .constant(-1), isSearchResult: .constant(true)), isActive: self.$showingPost) {
                EmptyView()
            }.isDetailLink(false).hidden().allowsHitTesting(false)
            
            TagsWebView(webViewLoading: self.$webViewLoading, webViewProgress: self.$webViewProgress, goToPostId: self.$goToPostId, showingPost: self.$showingPost)
        }

        // View settings
        .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Tags", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 26, height: 16))
    }
}
