//
//  iPhoneContentView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 4/30/21.
//

import SwiftUI

struct iPhoneContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    func navigateTo(_ goToDestination: inout Bool) {
            appSessionStore.resetNavigation()
            goToDestination = true
        }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HomeButtons()
                    TrendingView()
                    ArticlesView()
                }
                .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
            }
            .navigationBarTitle("Evening Reading")
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(true)
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarItems(trailing: SettingsButton())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(colorScheme == .dark ? Color.white : Color(UIColor.systemBlue))
        .overlay(appSessionStore.showingHomeScreen ? Color("ClearColor").frame(width: 0, height: 0).offset(y: 0) : Color("HomeScreenOverlay").frame(width: 2600, height: 2600).offset(y: -80) )
    }
}

struct iPhoneContentView_Previews: PreviewProvider {
    static var previews: some View {
        iPhoneContentView()
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore())
    }
}
