//
//  GoToPostView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/10/21.
//

import SwiftUI

struct GoToPostView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    @State private var goToPostId: Int = 0
    @State private var showingGoTo: Bool = false

    var body: some View {
        NavigationLink(destination: ThreadDetailView(threadId: .constant(0), postId: self.$goToPostId), isActive: self.$showingGoTo) {
            EmptyView()
        }
        .onReceive(appSessionStore.$showingShackLink) { value in
            if value {
                if appSessionStore.shackLinkPostId != "" {
                    self.appSessionStore.showingShackLink = false
                    self.goToPostId = Int(appSessionStore.shackLinkPostId) ?? 0
                    self.showingGoTo = true
                }
            }
        }
    }
}

struct GoToPostView_Previews: PreviewProvider {
    static var previews: some View {
        GoToPostView()
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
