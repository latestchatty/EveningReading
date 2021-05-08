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
    
    @State private var showingGuidelinesView = false
    
    var body: some View {
        NavigationView {            
            ScrollView {
                VStack {
                    GuidelinesView(showingGuidelinesView: $showingGuidelinesView)
                    .onAppear() {
                        DispatchQueue.main.async {
                            let defaults = UserDefaults.standard
                            let guidelinesAccepted = defaults.object(forKey: "GuidelinesAccepted") as? Bool ?? false
                            self.showingGuidelinesView = !guidelinesAccepted
                        }
                    }
                    iPhoneHomeButtons()
                        .environmentObject(appSessionStore)
                        .environmentObject(chatStore)
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
        .overlay(appSessionStore.showingHomeScreen ? Color("ClearColor").frame(width: 0, height: 0).offset(y: 0) : Color("HomeScreenOverlay").frame(width: 2600, height: 2600).offset(y: -80) )
    }
}

struct iPhoneContentView_Previews: PreviewProvider {
    static var previews: some View {
        iPhoneContentView()
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
            .environmentObject(ArticleStore(service: ArticleService()))
    }
}
