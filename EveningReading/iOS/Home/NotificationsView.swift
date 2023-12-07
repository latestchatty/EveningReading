//
//  NotificationsView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/19/21.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    var body: some View {
        VStack {
            
            // Heading
            VStack {
                HStack {
                    Text("Notifications")
                        .font(.title2)
                        .fontWeight(.heavy)
                    Spacer()
                }
                .padding(.horizontal, UIScreen.main.bounds.width <= 375 ? 35 : 20)
            }
            .padding(.top, 20)
            
            // Notification list
            if appSessionStore.pushNotifications.count > 0 {
                ScrollView(.horizontal) {
                    HStack {
                        Spacer().frame(width: 25)
                        ForEach(appSessionStore.pushNotifications.reversed(), id: \.self) { notification in
                            NavigationLink(destination: ThreadDetailView(threadId: .constant(0), postId: .constant(notification.postId), replyCount: .constant(-1), isSearchResult: .constant(true))) {
                            
                                NotificationPreviewView(title: notification.title, postBody: notification.body, postId: notification.postId)

                            }.isDetailLink(false)
                        }
                        NotificationsClearView()
                        Spacer().frame(width: 25)
                    }
                }
            } else {
                HStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("No notifications.")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color("NoDataLabel"))
                                .lineLimit(1)
                        }
                        .frame(alignment: .leading)
                        .padding(20)
                    }
                    .frame(maxWidth: 320)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
