//
//  macOSSettingsView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct macOSSettingsView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    private func version() -> String {
        let dict = Bundle.main.infoDictionary!
        if let version = dict["CFBundleShortVersionString"] as? String {
            return version
        } else {
            return "1.0"
        }
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            Form {
                /*
                Section(header: Text("PREFERENCES")) {
                    PreferencesView()
                        .environmentObject(appSessionStore)
                }
                */
                Section(header: Text("ACCOUNT")) {
                    macOSAccountView()
                        .environmentObject(appSessionStore)
                }
                Spacer().frame(height: 20)
                Section(header: Text("CATEGORIES")) {
                    CategoriesView()
                        .environmentObject(appSessionStore)
                }
                Spacer().frame(height: 20)
                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("Version")
                        Text("\(self.version())")
                    }
                    .padding(.vertical, 5)
                    HStack {
                        Link("Guidelines", destination: URL(string: "https://www.shacknews.com/guidelines")!).font(.callout).foregroundColor(Color(NSColor.linkColor))
                        Spacer()
                    }
                }
            }
            .padding(.leading, 20)
            .padding(.top, 20)
            
            Spacer()
            
            VStack {
                Spacer().frame(maxWidth: .infinity).frame(height: 0)
            }
        }
        .navigationTitle("Settings")
    }
}

struct macOSSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        macOSSettingsView()
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
