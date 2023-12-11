//
//  GoToShackLinkView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/10/21.
//

import SwiftUI

struct GoToShackLinkView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var notifications: Notifications
    @EnvironmentObject var chatService: ChatService
    
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
            .onChange(of: appService.showingShackLink, perform: { value in
                print(".onReceive(appService.$showingShackLink)")
                if value {
                    print("going to try to show link")
                    if appService.shackLinkPostId != "" {
                        print("showing link")
                        self.appService.showingShackLink = false
                        self.goToPostId = Int(appService.shackLinkPostId) ?? 0
                        appService.showingPostId = Int(appService.shackLinkPostId) ?? 0
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
