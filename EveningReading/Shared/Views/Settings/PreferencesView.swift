//
//  PreferencesView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var appSession: AppSession
    var body: some View {
        Group {
            #if os(iOS)
            Toggle(isOn: self.$appSession.displayPostAuthor) {
                Text("Display Authors")
            }
            Toggle(isOn: self.$appSession.abbreviateThreads) {
                Text("Abbreviate Threads")
            }
            Toggle(isOn: self.$appSession.isDarkMode) {
                Text("Dark Mode")
            }
            Toggle(isOn: self.$appSession.threadNavigation) {
                Text("Thread Navigation")
            }
            Toggle(isOn: self.$appSession.useYoutubeApp) {
                Text("Use YouTube App")
            }
            Toggle(isOn: self.$appSession.showLinkCopyButton) {
                Text("Copy Link Button")
            }
            #endif
            Toggle(isOn: self.$appSession.disableAnimation) {
                Text("Disable Animation")
            }
        }
    }
}
