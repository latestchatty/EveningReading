//
//  SettingsView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct SettingsView: View {
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
        Form {
            Section(header: Text("PREFERENCES")) {
                PreferencesView()
            }
            Section(header: Text("ACCOUNT")) {
                AccountView()
            }
            Section(header: Text("CATEGORIES")) {
                CategoriesView()
            }
            Section(header: Text("ABOUT")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("\(self.version())")
                }
                HStack {
                    Link("Guidelines", destination: URL(string: "https://www.shacknews.com/guidelines")!).font(.callout).foregroundColor(Color(UIColor.link))
                    Spacer()
                }
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
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
