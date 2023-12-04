//
//  SidebarButtons.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct SidebarButtons: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    private func navigateTo(_ goToDestination: inout Bool) {
        appSessionStore.resetNavigation()
        goToDestination = true
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            SidebarButton(text: .constant("Chat"), imageName: .constant("text.bubble"), selected: $appSessionStore.showingChatView)
                .onTapGesture(count: 1) {
                    navigateTo(&appSessionStore.showingChatView)
                }
            
            /*
            SidebarButton(text: .constant("Inbox"), imageName: .constant("envelope.open"), selected: $appSessionStore.showingInboxView)
                .onTapGesture(count: 1) {
                    navigateTo(&appSessionStore.showingInboxView)
                }
            */
            
            /*
            SidebarButton(text: .constant("Search"), imageName: .constant("magnifyingglass"), selected: $appSessionStore.showingSearchView)
                .onTapGesture(count: 1) {
                    navigateTo(&appSessionStore.showingSearchView)
                }
            */
            
            SidebarButton(text: .constant("Tags"), imageName: .constant("tag"), selected: $appSessionStore.showingTagsView)
                .onTapGesture(count: 1) {
                    navigateTo(&appSessionStore.showingTagsView)
                }
            
            SidebarButton(text: .constant("Settings"), imageName: .constant("gear"), selected: $appSessionStore.showingSettingsView)
                .onTapGesture(count: 1) {
                    navigateTo(&appSessionStore.showingSettingsView)
                }
        }
    }
}

struct SidebarButtons_Previews: PreviewProvider {
    static var previews: some View {
        SidebarButtons()
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
