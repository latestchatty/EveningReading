//
//  macOSSettingsView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct macOSSettingsView: View {
    enum SettingsTab {
        case account
        case filters
        case general
        case about
    }
    @EnvironmentObject var appSession: AppSession
    @State private var activeTab: SettingsTab = SettingsTab.account
    
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
            HStack (spacing: 10) {
                VStack {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Account")
                }
                .foregroundColor(self.activeTab == .account ? Color(NSColor.systemTeal) : Color(NSColor.systemGray))
                .frame(width: 64, height: 64)
                .background(self.activeTab == .account ? Color("macOSSettingsButton") : Color.clear)
                .cornerRadius(4.0)
                .contentShape(Rectangle())
                .onTapGesture (count: 1) {
                    self.activeTab = .account
                }
                
                VStack {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Filters")
                }
                .foregroundColor(self.activeTab == .filters ? Color(NSColor.systemTeal) : Color(NSColor.systemGray))
                .frame(width: 64, height: 64)
                .background(self.activeTab == .filters ? Color("macOSSettingsButton") : Color.clear)
                .cornerRadius(4.0)
                .contentShape(Rectangle())
                .onTapGesture (count: 1) {
                    self.activeTab = .filters
                }
                
                VStack {
                    Image(systemName: "gear.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("General")
                }
                .foregroundColor(self.activeTab == .general ? Color(NSColor.systemTeal) : Color(NSColor.systemGray))
                .frame(width: 64, height: 64)
                .background(self.activeTab == .general ? Color("macOSSettingsButton") : Color.clear)
                .cornerRadius(4.0)
                .contentShape(Rectangle())
                .onTapGesture (count: 1) {
                    self.activeTab = .general
                }
                
                VStack {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("About")
                }
                .foregroundColor(self.activeTab == .about ? Color(NSColor.systemTeal) : Color(NSColor.systemGray))
                .frame(width: 64, height: 64)
                .background(self.activeTab == .about ? Color("macOSSettingsButton") : Color.clear)
                .cornerRadius(4.0)
                .contentShape(Rectangle())
                .onTapGesture (count: 1) {
                    self.activeTab = .about
                }
            }
            .padding(.top, 20)
            .frame(maxWidth: .infinity)
            
            Form {
                if self.activeTab == .account {
                    macOSAccountView()
                        .environmentObject(appSession)
                }

                if self.activeTab == .filters {
                    VStack (alignment: .center) {
                        VStack (alignment: .leading) {
                            CategoriesView()
                                .environmentObject(appSession)
                        }
                        macOSClearHiddenView()
                            .environmentObject(appSession)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                if self.activeTab == .general {
                    VStack (alignment: .center) {
                        macOSGeneralView()
                            .environmentObject(appSession)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                if self.activeTab == .about {
                    VStack (alignment: .center) {
                        HStack {
                            Text("Version")
                            Text("\(self.version())")
                        }
                        .padding(.vertical, 5)
                        HStack {
                            Link("Guidelines", destination: URL(string: "https://www.shacknews.com/guidelines")!).font(.callout).foregroundColor(Color(NSColor.linkColor))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 20)
            
            Spacer()
            
            VStack {
                Spacer().frame(maxWidth: .infinity).frame(height: 0)
            }
        }
        .navigationTitle("Settings")
    }
}
