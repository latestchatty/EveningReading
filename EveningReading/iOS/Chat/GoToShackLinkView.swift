//
//  GoToShackLinkView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/10/21.
//

import SwiftUI

struct GoToShackLinkView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSession: AppSession
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
            .onChange(of: appSession.showingShackLink, perform: { value in
                print(".onReceive(appSession.$showingShackLink)")
                if value {
                    print("going to try to show link")
                    if appSession.shackLinkPostId != "" {
                        print("showing link")
                        self.appSession.showingShackLink = false
                        self.goToPostId = Int(appSession.shackLinkPostId) ?? 0
                        appSession.showingPostId = Int(appSession.shackLinkPostId) ?? 0
                        self.showingPost = true
                    }
                }
            })
            
            // Push ThreadDetailView
            NavigationLink(destination: ThreadDetailView(threadId: 0, postId: self.goToPostId, replyCount: -1, isSearchResult: true), isActive: self.$showingPost) {
                EmptyView()
            }.isDetailLink(false).hidden().allowsHitTesting(false)
            
        }
        .frame(width: 0, height: 0)
    }
}
