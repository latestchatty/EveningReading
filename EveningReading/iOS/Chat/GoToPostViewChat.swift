//
//  GoToPostViewChat.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/10/21.
//

import SwiftUI

struct GoToPostViewChat: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var notifications: Notifications
    @EnvironmentObject var chatStore: ChatStore
    
    @State private var goToPostId: Int = 0
    @State private var showingPost: Bool = false
    @State private var showingAlert: Bool = false
    
    var body: some View {
        VStack {
            // Fixes navigation bug
            // https://developer.apple.com/forums/thread/677333
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.hidden().disabled(true).allowsHitTesting(false)
            
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.hidden().disabled(true).allowsHitTesting(false)
            
            // Push ThreadDetailView
            NavigationLink(destination: ThreadDetailView(threadId: .constant(0), postId: $appSessionStore.showingPostId, replyCount: .constant(-1), isSearchResult: .constant(true)), isActive: $appSessionStore.showingPostWithChat[appSessionStore.showingPostId].unwrap() ?? .constant(false)) {
                EmptyView()
            }.isDetailLink(false).hidden().allowsHitTesting(false)
            
            // Deep link to post from push notification
            .onReceive(notifications.$notificationData) { value in
                print(".onReceive(notifications.$notificationData)")
                
                if let postId = value?.notification.request.content.userInfo["postid"], let body = value?.notification.request.content.body, let title = value?.notification.request.content.title {
                    print("got postId \(postId), previously showed \(appSessionStore.showingPostId)")
                    if String("\(postId)").isInt && appSessionStore.showingPostId != Int(String("\(postId)")) ?? 0 {

                        notifications.notificationData = nil
                        print("setting postID \(postId)")
                        appSessionStore.showingPostId = Int(String("\(postId)")) ?? 0
                        print("going to post \(Int(String("\(postId)")) ?? 0)")
                        appSessionStore.showingPostWithChat[appSessionStore.showingPostId] = true
                        
                        appSessionStore.pushNotifications.append(PushNotification(title: title, body: body, postId: Int(String("\(postId)")) ?? 0))
                    }
                }
            }
        }
        .frame(width: 0, height: 0)
    }
}

struct GoToPostViewChat_Previews: PreviewProvider {
    static var previews: some View {
        GoToPostViewChat()
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(Notifications())
            .environmentObject(ChatStore(service: ChatService()))
    }
}
