//
//  EveningReadingApp.swift
//  Shared
//
//  Created by Chris Hodge on 4/28/21.
//

import SwiftUI

@main
struct EveningReadingApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadContentView()
            } else {
                iPhoneContentView()
            }
            #else
                macOSContentView()
            #endif
        }
    }
}
