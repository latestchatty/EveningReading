//
//  FilterSettingsView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/7/21.
//

import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var appSession: AppSession
    
    var body: some View {
        Group {
            #if os(macOS)
            Toggle(isOn: self.$appSession.hideBadWords) {
                Text("Language")
            }
            #endif
            Toggle(isOn: self.$appSession.showInformative) {
                Text("Informative")
            }
            Toggle(isOn: self.$appSession.showOffTopic) {
                Text("Off Topic")
            }
            Toggle(isOn: self.$appSession.showPolitical) {
                Text("Political")
            }
            Toggle(isOn: self.$appSession.showStupid) {
                Text("Stupid")
            }
            Toggle(isOn: self.$appSession.showNWS) {
                Text("NWS")
            }
        }
    }
}

