//
//  iPadContentView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 4/30/21.
//

import SwiftUI

struct iPadContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService
    @EnvironmentObject var notifications: PushNotifications
    @EnvironmentObject var shackTags: ShackTags
    
    @State private var showingGuidelinesView = false
    
    var body: some View {
        NavigationView {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack {
                        GoToPostViewHome()
                        GuidelinesView(showingGuidelinesView: self.$showingGuidelinesView)
                        .onAppear() {
                            DispatchQueue.main.async {
                                let defaults = UserDefaults.standard
                                let guidelinesAccepted = defaults.object(forKey: "GuidelinesAccepted") as? Bool ?? false
                                self.showingGuidelinesView = !guidelinesAccepted
                            }
                        }
                        iPadHomeButtons()
                            .environmentObject(appService)
                            .environmentObject(chatService)
                        TrendingView()
                        iPadArticlesView()
                    }
                    .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
                }
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
            if !appService.didRegisterForPush {
                appService.didRegisterForPush = true
                NotificationStore(service: .init()).registernew()
            }
        }
    }
}

