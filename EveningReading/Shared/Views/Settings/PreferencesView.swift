//
//  PreferencesView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var appService: AppService
    var body: some View {
        Group {
            #if os(iOS)
            Toggle(isOn: self.$appService.displayPostAuthor) {
                Text("Display Authors")
            }
            Toggle(isOn: self.$appService.abbreviateThreads) {
                Text("Abbreviate Threads")
            }
            Toggle(isOn: self.$appService.isDarkMode) {
                Text("Dark Mode")
            }
            Toggle(isOn: self.$appService.threadNavigation) {
                Text("Thread Navigation")
            }
            Toggle(isOn: self.$appService.useYoutubeApp) {
                Text("Use YouTube App")
            }
            Toggle(isOn: self.$appService.showLinkCopyButton) {
                Text("Copy Link Button")
            }
            #endif
            Toggle(isOn: self.$appService.disableAnimation) {
                Text("Disable Animation")
            }
        }
    }
}
