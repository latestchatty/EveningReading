//
//  GoToPostViewHome.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/10/21.
//

import SwiftUI

struct GoToPostViewHome: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSessionStore: AppSessionStore
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
            NavigationLink(destination: ThreadDetailView(threadId: .constant(0), postId: $appSessionStore.showingPostId, replyCount: .constant(-1), isSearchResult: .constant(true)), isActive: $appSessionStore.showingPushNotificationThread) {
                            EmptyView()
            }.isDetailLink(false).hidden().allowsHitTesting(false)
            
            // Deep link to post from push notification
            .onReceive(notifications.$notificationData) { value in
                if let postId = value?.notification.request.content.userInfo["postid"], let body = value?.notification.request.content.body, let title = value?.notification.request.content.title {
                    if String("\(postId)").isInt && appSessionStore.showingPostId != Int(String("\(postId)")) ?? 0 {
                        
                        //notifications.notificationData = nil
                        
                        appSessionStore.showingPostId = Int(String("\(postId)")) ?? 0
                        
                        let newNotification = PushNotification(title: title, body: body, postId: Int(String("\(postId)")) ?? 0)
                        
                        if !appSessionStore.pushNotifications.contains(newNotification) {
                            appSessionStore.pushNotifications.append(newNotification)
                            
                            appSessionStore.resetNavigation()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                                //self.showingPost = true
                                appSessionStore.showingPushNotificationThread = true
                            }
                            
                            //if appSessionStore.currentViewName == "HomeView" {
                            //    appSessionStore.showingPushNotificationThread = true
                            //}
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
