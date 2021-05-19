//
//  PushNotificationView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/8/21.
//

import Foundation
import SwiftUI

struct PushNotificationViewChat: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var notifications: Notifications
    @EnvironmentObject var chatStore: ChatStore

    @State private var isAlertShowing: Bool = false

    var body: some View {
        VStack {
            if appSessionStore.showingPostChat {
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
                                //self.isAlertShowing.toggle()
                                appSessionStore.showingPostChat = false
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
                        NavigationLink(destination: ThreadDetailView(threadId: .constant(0), postId: $appSessionStore.showingPostIdChat, replyCount: .constant(-1), isSearchResult: .constant(true))) {
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
            print(".onReceive(notifications.$notificationData) Chat")
            if self.enabled {
                if let postId = value?.notification.request.content.userInfo["postid"] {
                    print("got postId \(postId), previously showed \(appSessionStore.showingPostId)")
                    if String("\(postId)").isInt && appSessionStore.showingPostIdChat != Int(String("\(postId)")) ?? 0 {
                        print("prompting for postID \(postId)")
                        //appSessionStore.showingPostId = Int(String("\(postId)")) ?? 0
                        appSessionStore.showingPostIdChat = Int(String("\(postId)")) ?? 0
                        if appSessionStore.showingPostIdChat != 0 && appSessionStore.showingPostIdChat != appSessionStore.showingPostIdThread && appSessionStore.showingPostIdChat != appSessionStore.showingPostIdHome {
                            appSessionStore.showingPostChat = true
                            self.isAlertShowing = true
                        }
                    }
                }
            }
        }
        .onAppear() {
            self.enabled = true
        }
        .onDisappear() {
            self.enabled = false
        }
    }
}

struct PushNotificationViewChat_Previews: PreviewProvider {
    
    static var previews: some View {
        PushNotificationViewChat()
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(Notifications())
            .environmentObject(ChatStore(service: ChatService()))
    }
}
