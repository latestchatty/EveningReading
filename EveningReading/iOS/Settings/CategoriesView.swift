//
//  FilterSettingsView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/7/21.
//

import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var appService: AppService
    
    var body: some View {
        Group {
            #if os(macOS)
            Toggle(isOn: self.$appService.hideBadWords) {
                Text("Language")
            }
            #endif
            Toggle(isOn: self.$appService.showInformative) {
                Text("Informative")
            }
            Toggle(isOn: self.$appService.showOffTopic) {
                Text("Off Topic")
            }
            Toggle(isOn: self.$appService.showPolitical) {
                Text("Political")
            }
            Toggle(isOn: self.$appService.showStupid) {
                Text("Stupid")
            }
            Toggle(isOn: self.$appService.showNWS) {
                Text("NWS")
            }
        }
    }
}

