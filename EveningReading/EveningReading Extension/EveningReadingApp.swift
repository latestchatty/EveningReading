//
//  EveningReadingApp.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 4/30/21.
//

import SwiftUI

@main
struct EveningReadingApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                watchOSContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
