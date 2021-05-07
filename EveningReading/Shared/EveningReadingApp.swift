//
//  EveningReadingApp.swift
//  Shared
//
//  Created by Chris Hodge on 4/28/21.
//

import SwiftUI

@main
struct EveningReadingApp: App {
    @StateObject var appSessionStore = AppSessionStore(service: .init())
    @StateObject var chatStore = ChatStore(service: .init())
    
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadContentView()
                    .environmentObject(appSessionStore)
                    .environmentObject(chatStore)
            } else {
                iPhoneContentView()
                    .environmentObject(appSessionStore)
                    .environmentObject(chatStore)
            }
            #else
                macOSContentView()
                    .environmentObject(appSessionStore)
                    .environmentObject(chatStore)
            #endif
        }
    }
}
