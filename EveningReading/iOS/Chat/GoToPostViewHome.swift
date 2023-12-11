//
//  GoToPostViewHome.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/10/21.
//

import SwiftUI

struct GoToPostViewHome: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSession: AppSession
    @EnvironmentObject var notifications: Notifications
    @EnvironmentObject var chatStore: ChatStore
    
    @State private var goToPostId: Int = 0
    @State private var showingPost: Bool = false
    
    var body: some View {
        VStack {
            // Fixes navigation bug
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.hidden().disabled(true).allowsHitTesting(false)
            
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.hidden().disabled(true).allowsHitTesting(false)
            
            // Push ThreadDetailView
            NavigationLink(destination: ThreadDetailView(threadId: 0, postId: appSession.showingPostId, replyCount: -1, isSearchResult: true), isActive: $appSession.showingPushNotificationThread) {
                            EmptyView()
            }.isDetailLink(false).hidden().allowsHitTesting(false)
            
            // Deep link to post from push notification
            .onReceive(notifications.$notificationData) { value in
                if let postId = value?.notification.request.content.userInfo["postid"], let body = value?.notification.request.content.body, let title = value?.notification.request.content.title {
                    if String("\(postId)").isInt && appSession.showingPostId != Int(String("\(postId)")) ?? 0 {
                        appSession.showingPostId = Int(String("\(postId)")) ?? 0
                        let newNotification = PushNotification(title: title, body: body, postId: Int(String("\(postId)")) ?? 0)
                        if !appSession.pushNotifications.contains(newNotification) {
                            appSession.pushNotifications.append(newNotification)
                            
                            appSession.resetNavigation()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                                appSession.showingPushNotificationThread = true
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)) {
                            notifications.notificationData = nil
                        }
                    }
                }
            }
            
        }
        .frame(width: 0, height: 0)
    }
}
