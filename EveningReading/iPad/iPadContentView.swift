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
    @EnvironmentObject var articleStore: ArticleStore
    @EnvironmentObject var messageStore: MessageStore
    @EnvironmentObject var notifications: Notifications
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
                            appSessionStore.currentViewName = "HomeView"
                        }
                        iPadHomeButtons()
                            .environmentObject(appSessionStore)
                            .environmentObject(chatStore)
                        TrendingView()
                        iPadArticlesView()
                            .environmentObject(articleStore)
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(colorScheme == .dark ? Color.white : Color(UIColor.systemBlue))
        .onAppear() {
            if !appSessionStore.didRegisterForPush {
                appSessionStore.didRegisterForPush = true
                NotificationStore(service: .init()).registernew()
            }
        }
    }
}

struct iPadContentView_Previews: PreviewProvider {
    static var previews: some View {
        iPadContentView()
            .previewDevice(PreviewDevice(rawValue: "iPad (8th generation)"))
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
            .environmentObject(ArticleStore(service: ArticleService()))
            .environmentObject(MessageStore(service: MessageService()))
            .environmentObject(Notifications())
            .environmentObject(ShackTags())
    }
}
