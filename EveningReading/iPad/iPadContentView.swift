//
//  iPadContentView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 4/30/21.
//

import SwiftUI

struct iPadContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore

    var body: some View {
        NavigationView {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack {
                        iPadHomeButtons()
                            .environmentObject(appSessionStore)
                            .environmentObject(chatStore)
                        TrendingView()
                        iPadArticlesView()
                    }
                    .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle("Evening Reading")
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(trailing: SettingsButton())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(colorScheme == .dark ? Color.white : Color(UIColor.systemBlue))
        .overlay(appSessionStore.showingHomeScreen ? Color("ClearColor").frame(width: 0, height: 0).offset(y: 0) : Color("HomeScreenOverlay").frame(width: 2600, height: 2600).offset(y: -80) )
    }
}

struct iPadContentView_Previews: PreviewProvider {
    static var previews: some View {
        iPadContentView()
            .previewDevice(PreviewDevice(rawValue: "iPad (8th generation)"))
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
