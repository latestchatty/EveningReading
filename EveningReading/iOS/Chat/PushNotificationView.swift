//
//  PushNotificationView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/8/21.
//

import Foundation
import SwiftUI

struct PushNotificationView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var notifications: Notifications
    @EnvironmentObject var chatStore: ChatStore

    @Binding var isAlertShowing: Bool

    var body: some View {
        VStack {
            if self.isAlertShowing {
                VStack {
                    Spacer()
                    Text("View post?")
                        .bold()
                        .foregroundColor(Color(UIColor.label))
                        .offset(x: 0, y: 5)
                    Spacer()
                    Rectangle()
                        .fill(Color(UIColor.systemGray2))
                        .frame(height: 1)
                        .offset(x: 0, y: 8)
                    HStack {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.1)) {
                                self.isAlertShowing.toggle()
                            }
                        }) {
                            Text("Close")
                                .bold()
                                .foregroundColor(Color(UIColor.link))
                        }
                        .frame(width: 120, height: 30)
                        .foregroundColor(.white)
                        Rectangle()
                            .fill(Color(UIColor.systemGray2))
                            .frame(width: 1)                        
                        NavigationLink(destination: ThreadDetailView(threadId: .constant(0), postId: $appSessionStore.showingPostId, replyCount: .constant(-1), isSearchResult: .constant(true))) {
                            Text("Yes")
                                .foregroundColor(Color(UIColor.link))
                        }
                        .frame(width: 120, height: 30)
                    }
                    .frame(height: 50)
                }
                .frame(width: 290, height: 120)
                .background(colorScheme == .dark ? Color(UIColor.systemGray4).opacity(0.9) : Color.white.opacity(0.9))
                .cornerRadius(12)
                .clipped()
                .shadow(radius: 5)
                .transition(.scale)
            } else {
                EmptyView()
            }
        }
        // Deep link to post from push notification
        .onReceive(notifications.$notificationData) { value in
            print(".onReceive(notifications.$notificationData)")
            if let postId = value?.notification.request.content.userInfo["postid"] {
                print("got postId \(postId), previously showed \(appSessionStore.showingPostId)")
                if String("\(postId)").isInt && appSessionStore.showingPostId != Int(String("\(postId)")) ?? 0 {
                    print("prompting for postID \(postId)")
                    appSessionStore.showingPostId = Int(String("\(postId)")) ?? 0
                    self.isAlertShowing = true
                }
            }
        }
    }
}

struct PushNotificationView_Previews: PreviewProvider {
    
    static var previews: some View {
        PushNotificationView(isAlertShowing: .constant(true))
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(Notifications())
            .environmentObject(ChatStore(service: ChatService()))
    }
}