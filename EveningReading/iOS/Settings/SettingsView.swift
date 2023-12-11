//
//  SettingsView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appService: AppService
    
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
                if UIDevice.current.userInterfaceIdiom == .phone {
                    NavigationLink(destination: SyncWatchView()) {
                        HStack {
                            Text("Sync With Watch")
                            Spacer()
                            Image("chevron.right")
                        }
                        .contentShape(Rectangle())
                    }.isDetailLink(false)
                }
            }
            Section(header: Text("FILTERS")) {
                CategoriesView()
                NavigationLink(destination: FavoriteUsersView()) {
                    HStack {
                        Text("Favorite Users")
                        Spacer()
                        Image("chevron.right")
                    }
                    .contentShape(Rectangle())
                }.isDetailLink(false)
                ClearHiddenView()
                ClearBlockedView()
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
