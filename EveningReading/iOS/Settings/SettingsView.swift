//
//  SettingsView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("PREFERENCES")) {
                PreferencesView()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitle("Settings", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 16, height: 16))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
