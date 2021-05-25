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
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var articleStore: ArticleStore
    @EnvironmentObject var messageStore: MessageStore
    @EnvironmentObject var notifications: Notifications
    //@EnvironmentObject var notificationStore: NotificationStore
    
    @State private var showingGuidelinesView = false
    @State private var showingPost: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    /*
                    // Push thread detail view
                    NavigationLink(destination: ThreadDetailView(threadId: .constant(0), postId: $appSessionStore.showingPostId, replyCount: .constant(-1), isSearchResult: .constant(true)), isActive: self.$showingPost) {
                        EmptyView()
                    }.isDetailLink(false).hidden().allowsHitTesting(false)
                    */
                    
                    GoToPostViewHome()
                    GuidelinesView(showingGuidelinesView: $showingGuidelinesView)
                    .onAppear() {
                        DispatchQueue.main.async {
                            let defaults = UserDefaults.standard
                            let guidelinesAccepted = defaults.object(forKey: "GuidelinesAccepted") as? Bool ?? false
                            self.showingGuidelinesView = !guidelinesAccepted
                        }
                        
                        // Respond to push notification
                        appSessionStore.currentViewName = "HomeView"
                        /*
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                            print("showingPost =  \(appSessionStore.showingPost.description)")
                            if appSessionStore.showingPost {
                                print("will show post")
                                self.showingPost = true
                            }
                        }
                        */
                        
                    }
                    iPhoneHomeButtons()
                        .environmentObject(appSessionStore)
                        .environmentObject(chatStore)
                    NotificationsView()
                    TrendingView()
                    iPhoneArticlesView()
                        .environmentObject(articleStore)
                }
                .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle("Evening Reading")
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(trailing: SettingsButton())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(colorScheme == .dark ? Color.white : Color(UIColor.systemBlue))
        //.overlay(appSessionStore.showingPost ? Color("PrimaryBackground").frame(width: 2600, height: 2600).offset(y: -80) : Color.clear.frame(width: 0, height: 0).offset(y: 0))
        .onAppear() {
            /*
            if Notifications.shared.notificationLink != "" {
                print("responding to notficationlink \(Notifications.shared.notificationLink)")
                Notifications.shared.notificationLink = ""
            }
            */
        }
    }
}

struct iPhoneContentView_Previews: PreviewProvider {
    static var previews: some View {
        iPhoneContentView()
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
            .environmentObject(ArticleStore(service: ArticleService()))
            .environmentObject(MessageStore(service: MessageService()))
            .environmentObject(Notifications())
            //.environmentObject(NotificationStore(service: NotificationService()))
    }
}
