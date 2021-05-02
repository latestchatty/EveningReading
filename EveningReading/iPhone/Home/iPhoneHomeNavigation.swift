//
//  iPhoneHomeNavigation.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct iPhoneHomeNavigation: View {
    @EnvironmentObject var appSessionStore: AppSessionStore

    private func navigateTo(_ goToDestination: inout Bool) {
        appSessionStore.resetNavigation()
        goToDestination = true
    }
    
    var body: some View {
        HStack {

            // Home Screen Navigation
            VStack {
                // go to chat
                NavigationLink(destination: ChatView(), isActive: $appSessionStore.showingChatView) {
                    Spacer().frame(width: 0, height: 0)
                }
                
                // go to inbox
                NavigationLink(destination: InboxView(), isActive: $appSessionStore.showingInboxView) {
                    Spacer().frame(width: 0, height: 0)
                }
                
                // go to search
                NavigationLink(destination: SearchView(populateTerms: .constant(""), populateAuthor: .constant(""), populateParent: .constant("")), isActive: $appSessionStore.showingSearchView) {
                    Spacer().frame(width: 0, height: 0)
                }
                
                // go to tags
                NavigationLink(destination: TagsView(), isActive: $appSessionStore.showingTagsView) {
                    Spacer().frame(width: 0, height: 0)
                }
                
                // go to settings
                NavigationLink(destination: SettingsView(), isActive: $appSessionStore.showingSettingsView) {
                    Spacer().frame(width: 0, height: 0)
                }
            }
            
            // Settings
            Button(action: {
                navigateTo(&appSessionStore.showingSettingsView)
            }) {
                Image(systemName: "person.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .imageScale(.large)
                    .frame(width: 36)
            }
        }
    }
}

struct iPhoneHomeNavigation_Previews: PreviewProvider {
    static var previews: some View {
        iPhoneHomeNavigation()
            .environmentObject(AppSessionStore())
    }
}
