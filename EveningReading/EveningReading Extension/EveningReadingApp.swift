//
//  EveningReadingApp.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 4/30/21.
//

import SwiftUI

@main
struct EveningReadingApp: App {
    @StateObject var appSession = AppSession()
    @StateObject var chatStore = ChatStore(service: .init())
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                watchOSContentView()
                    .environmentObject(appSession)
                    .environmentObject(chatStore)
                    
                .navigationTitle("Chat")
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
