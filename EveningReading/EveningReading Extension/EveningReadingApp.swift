//
//  EveningReadingApp.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 4/30/21.
//

import SwiftUI

@main
struct EveningReadingApp: App {
    @StateObject var appSessionStore = AppSessionStore(service: .init())
    @StateObject var chatStore = ChatStore(service: .init())
    @StateObject var messageStore = MessageStore(service: .init())
        
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                watchOSContentView()
                    .environmentObject(appSessionStore)
                    .environmentObject(chatStore)
                    .environmentObject(messageStore)
                    
                .navigationTitle("Chat")
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
