//
//  FilterSettingsView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/7/21.
//

import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    var body: some View {
        Group {
            #if os(macOS)
            Toggle(isOn: self.$appSessionStore.hideBadWords) {
                Text("Language")
            }
            #endif
            Toggle(isOn: self.$appSessionStore.showInformative) {
                Text("Informative")
            }
            Toggle(isOn: self.$appSessionStore.showOffTopic) {
                Text("Off Topic")
            }
            Toggle(isOn: self.$appSessionStore.showPolitical) {
                Text("Political")
            }
            Toggle(isOn: self.$appSessionStore.showStupid) {
                Text("Stupid")
            }
            Toggle(isOn: self.$appSessionStore.showNWS) {
                Text("NWS")
            }
        }
    }
}

