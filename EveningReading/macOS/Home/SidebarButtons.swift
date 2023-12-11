//
//  SidebarButtons.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct SidebarButtons: View {
    @EnvironmentObject var appSession: AppSession
    
    private func navigateTo(_ goToDestination: inout Bool) {
        appSession.resetNavigation()
        goToDestination = true
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            SidebarButton(text: .constant("Chat"), imageName: .constant("text.bubble"), selected: $appSession.showingChatView)
                .onTapGesture(count: 1) {
                    navigateTo(&appSession.showingChatView)
                }
            
            /*
            SidebarButton(text: .constant("Inbox"), imageName: .constant("envelope.open"), selected: $appSession.showingInboxView)
                .onTapGesture(count: 1) {
                    navigateTo(&appSession.showingInboxView)
                }
            */
            
            /*
            SidebarButton(text: .constant("Search"), imageName: .constant("magnifyingglass"), selected: $appSession.showingSearchView)
                .onTapGesture(count: 1) {
                    navigateTo(&appSession.showingSearchView)
                }
            */
            
            SidebarButton(text: .constant("Tags"), imageName: .constant("tag"), selected: $appSession.showingTagsView)
                .onTapGesture(count: 1) {
                    navigateTo(&appSession.showingTagsView)
                }
            
            SidebarButton(text: .constant("Settings"), imageName: .constant("gear"), selected: $appSession.showingSettingsView)
                .onTapGesture(count: 1) {
                    navigateTo(&appSession.showingSettingsView)
                }
        }
    }
}
