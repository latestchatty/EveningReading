//
//  GoToShackLinkView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/10/21.
//

import SwiftUI

struct GoToShackLinkView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var notifications: Notifications
    @EnvironmentObject var chatStore: ChatStore
    
    @State private var goToPostId: Int = 0
    @State private var showingPost: Bool = false
    @State private var showingAlert: Bool = false
    
    var body: some View {
        VStack {
            // Fixes navigation bug
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.hidden().disabled(true).allowsHitTesting(false)
            
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.hidden().disabled(true).allowsHitTesting(false)
            
            // Deep link to specific shack post
            .onChange(of: appSessionStore.showingShackLink, perform: { value in
                print(".onReceive(appSessionStore.$showingShackLink)")
                if value {
                    print("going to try to show link")
                    if appSessionStore.shackLinkPostId != "" {
                        print("showing link")
                        self.appSessionStore.showingShackLink = false
                        self.goToPostId = Int(appSessionStore.shackLinkPostId) ?? 0
                        appSessionStore.showingPostId = Int(appSessionStore.shackLinkPostId) ?? 0
                        self.showingPost = true
                    }
                }
            })
            
            // Push ThreadDetailView
            NavigationLink(destination: ThreadDetailView(threadId: .constant(0), postId: self.$goToPostId, replyCount: .constant(-1), isSearchResult: .constant(true)), isActive: self.$showingPost) {
                EmptyView()
            }.isDetailLink(false).hidden().allowsHitTesting(false)
            
        }
        .frame(width: 0, height: 0)
    }
}
