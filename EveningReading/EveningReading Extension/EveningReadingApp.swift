//
//  EveningReadingApp.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 4/30/21.
//

import SwiftUI

@main
struct EveningReadingApp: App {
    @StateObject var appService = AppService()
    @StateObject var chatService = ChatService(service: .init())
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                watchOSContentView()
                    .environmentObject(appService)
                    .environmentObject(chatService)
                    
                .navigationTitle("Chat")
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
