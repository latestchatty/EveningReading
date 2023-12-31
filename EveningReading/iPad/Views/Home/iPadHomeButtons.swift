//
//  iPadHomeButtons.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct iPadHomeButtons: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService
    
    @StateObject var messageViewModel = MessageViewModel()
    
    private func navigateTo(_ goToDestination: inout Bool) {
        appService.resetNavigation()
        goToDestination = true
    }
    
    private func getMessageCount() {
        messageViewModel.getCount()
    }

    var body: some View {
        HStack() {
            Spacer().frame(width: 20)
            
            // Buttons
            iPadHomeButton(title: "Chat", imageName: "glyphicons-basic-238-chat-message", buttonBackground: Color("HomeButtonChat"))
                .onTapGesture(count: 1) {
                    chatService.refreshChat()
                    navigateTo(&appService.showingChatView)
                }
            
            GeometryReader { geometry in
                iPadHomeButton(title: "Inbox", imageName: "glyphicons-basic-122-envelope-empty", buttonBackground: Color("HomeButtonInbox"))
                    .overlay(NewMessageBadgeView(notificationNumber: $messageViewModel.messageCount.unread, width: geometry.size.width), alignment: .top)
                    .onTapGesture(count: 1) {
                        navigateTo(&appService.showingInboxView)
                    }
                    .onAppear() {
                        getMessageCount()
                    }
            }
            iPadHomeButton(title: "Search", imageName: "glyphicons-basic-28-search", buttonBackground: Color("HomeButtonSearch"))
                .onTapGesture(count: 1) {
                    navigateTo(&appService.showingSearchView)
                }
            
            iPadHomeButton(title: "Tags", imageName: "glyphicons-basic-67-tags", buttonBackground: Color("HomeButtonTags"))
                .onTapGesture(count: 1) {
                    navigateTo(&appService.showingTagsView)
                }
            
            Spacer().frame(width: 20)
            
            // Home Screen Navigation
            VStack {
                // go to chat
                NavigationLink(destination: iPadChatView(), isActive: $appService.showingChatView) {
                    EmptyView()
                }
                
                // go to inbox
                NavigationLink(destination: InboxView(), isActive: $appService.showingInboxView) {
                    EmptyView()
                }
                
                // go to search
                NavigationLink(destination: SearchView(), isActive: $appService.showingSearchView) {
                    EmptyView()
                }
                
                // go to tags
                NavigationLink(destination: TagsView(), isActive: $appService.showingTagsView) {
                    EmptyView()
                }
                
                // go to settings
                NavigationLink(destination: SettingsView(), isActive: $appService.showingSettingsView) {
                    EmptyView()
                }
            }
            
        }
        .padding(.top, 10)
    }
}
