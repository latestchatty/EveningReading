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

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}