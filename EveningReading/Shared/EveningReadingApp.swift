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
    @StateObject var articleStore = ArticleStore(service: .init())
    
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadContentView()
                    .environmentObject(appSessionStore)
                    .environmentObject(chatStore)
                    .environmentObject(articleStore)
            } else {
                iPhoneContentView()
                    .environmentObject(appSessionStore)
                    .environmentObject(chatStore)
                    .environmentObject(articleStore)
            }
            #else
                macOSContentView()
                    .environmentObject(appSessionStore)
                    .environmentObject(chatStore)
                    .environmentObject(articleStore)
            #endif
        }
    }
}
