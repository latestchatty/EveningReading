//
//  GoToPostViewHome.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/10/21.
//

import SwiftUI

struct GoToPostViewHome: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var pushNotificationsService: PushNotificationsService
    @EnvironmentObject var chatService: ChatService
    
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
            NavigationLink(destination: ThreadDetailView(threadId: .constant(0), postId: appService.showingPostId, replyCount: -1, isSearchResult: true), isActive: $appService.showingPushNotificationThread) {
                            EmptyView()
            }.isDetailLink(false).hidden().allowsHitTesting(false)
            
            // Deep link to post from push notification
            .onReceive(pushNotificationsService.$notificationData) { value in
                if let postId = value?.notification.request.content.userInfo["postid"], let body = value?.notification.request.content.body, let title = value?.notification.request.content.title {
                    if String("\(postId)").isInt && appService.showingPostId != Int(String("\(postId)")) ?? 0 {
                        appService.showingPostId = Int(String("\(postId)")) ?? 0
                        let newNotification = PushNotification(title: title, body: body, postId: Int(String("\(postId)")) ?? 0)
                        if !appService.pushNotifications.contains(newNotification) {
                            appService.pushNotifications.append(newNotification)
                            
                            appService.resetNavigation()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                                appService.showingPushNotificationThread = true
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)) {
                            pushNotificationsService.notificationData = nil
                        }
                    }
                }
            }
            
        }
        .frame(width: 0, height: 0)
    }
}
