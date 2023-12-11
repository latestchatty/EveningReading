//
//  NotificationsView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/19/21.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var appService: AppService
    
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
            if appService.pushNotifications.count > 0 {
                ScrollView(.horizontal) {
                    HStack {
                        Spacer().frame(width: 25)
                        ForEach(appService.pushNotifications.reversed(), id: \.self) { notification in
                            NavigationLink(destination: ThreadDetailView(threadId: 0, postId: notification.postId, replyCount: -1, isSearchResult: true)) {
                            
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
