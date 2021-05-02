//
//  EveningReadingApp.swift
//  Shared
//
//  Created by Chris Hodge on 4/28/21.
//

import SwiftUI

@main
struct EveningReadingApp: App {
    @StateObject var appSessionStore = AppSessionStore()
    
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadContentView()
                    .environmentObject(appSessionStore)
            } else {
                iPhoneContentView()
                    .environmentObject(appSessionStore)
            }
            #else
                macOSContentView()
            #endif
        }
    }
}
