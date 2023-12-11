//
//  iPhoneContentView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 4/30/21.
//

import SwiftUI

struct iPhoneContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSession: AppSession
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var notifications: Notifications
    @EnvironmentObject var shackTags: ShackTags
    
    @State private var showingGuidelinesView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {                    
                    GoToPostViewHome()
                    GuidelinesView(showingGuidelinesView: $showingGuidelinesView)
                    .onAppear() {
                        DispatchQueue.main.async {
                            let defaults = UserDefaults.standard
                            let guidelinesAccepted = defaults.object(forKey: "GuidelinesAccepted") as? Bool ?? false
                            self.showingGuidelinesView = !guidelinesAccepted
                        }
                    }
                    iPhoneHomeButtons()
                        .environmentObject(appSession)
                        .environmentObject(chatStore)
                    TrendingView()
                    iPhoneArticlesView()
                }
                .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle(notifications.notificationData != nil ? "" : "Evening Reading")
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(trailing: SettingsButton())
            .overlay(LoadingPushNotificationView())
            .overlay(CopyPostView())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(colorScheme == .dark ? Color.white : Color(UIColor.systemBlue))
        .onAppear() {
            if !appSession.didRegisterForPush {
                appSession.didRegisterForPush = true
                NotificationStore(service: .init()).registernew()
            }
        }
    }
}

