//
//  iPhoneContentView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 4/30/21.
//

import SwiftUI

struct iPhoneContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService
    @EnvironmentObject var pushNotificationsService: PushNotificationsService
    @EnvironmentObject var shackTagService: ShackTagService
    
    @State private var showingGuidelinesView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {                    
                    GoToPostViewHome()
                    GuidelinesView(showingGuidelinesView: $showingGuidelinesView)
                    .onAppear() {
                        DispatchQueue.main.async {
                            self.showingGuidelinesView = !appService.didAcceptGuidelines()
                        }
                    }
                    iPhoneHomeButtons()
                        .environmentObject(appService)
                        .environmentObject(chatService)
                    TrendingView()
                    iPhoneArticlesView()
                }
                .background(Color("PrimaryBackground").frame(height: BackgroundHeight).offset(y: BackgroundOffset))
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle(pushNotificationsService.notificationData != nil ? "" : "Evening Reading")
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
                RegisterPushService().registernew()
            }
        }
    }
}

