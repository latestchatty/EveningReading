//
//  SidebarButtons.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct SidebarButtons: View {
    @EnvironmentObject var appService: AppService
    
    private func navigateTo(_ goToDestination: inout Bool) {
        appService.resetNavigation()
        goToDestination = true
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            SidebarButton(text: .constant("Chat"), imageName: .constant("text.bubble"), selected: $appService.showingChatView)
                .onTapGesture(count: 1) {
                    navigateTo(&appService.showingChatView)
                }
            
            /*
            SidebarButton(text: .constant("Inbox"), imageName: .constant("envelope.open"), selected: $appService.showingInboxView)
                .onTapGesture(count: 1) {
                    navigateTo(&appService.showingInboxView)
                }
            */
            
            /*
            SidebarButton(text: .constant("Search"), imageName: .constant("magnifyingglass"), selected: $appService.showingSearchView)
                .onTapGesture(count: 1) {
                    navigateTo(&appService.showingSearchView)
                }
            */
            
            SidebarButton(text: .constant("Tags"), imageName: .constant("tag"), selected: $appService.showingTagsView)
                .onTapGesture(count: 1) {
                    navigateTo(&appService.showingTagsView)
                }
            
            SidebarButton(text: .constant("Settings"), imageName: .constant("gear"), selected: $appService.showingSettingsView)
                .onTapGesture(count: 1) {
                    navigateTo(&appService.showingSettingsView)
                }
        }
    }
}
