//
//  iPhoneHomeButtons.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct iPhoneHomeButtons: View {
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
        VStack {
            Spacer().frame(height: 40)
            
            // Buttons
            HStack(alignment: .top) {
                iPhoneHomeButton(title: "Chat", imageName: "glyphicons-basic-238-chat-message", buttonBackground: Color("HomeButtonChat"))
                    .onTapGesture(count: 1) {
                        chatService.getChat()
                        navigateTo(&appService.showingChatView)
                    }
                Spacer()
                iPhoneHomeButton(title: "Inbox", imageName: "glyphicons-basic-122-envelope-empty", buttonBackground: Color("HomeButtonInbox"))
                    .overlay(NewMessageBadgeView(notificationNumber: $messageViewModel.messageCount.unread), alignment: .top)
                    .onTapGesture(count: 1) {
                        navigateTo(&appService.showingInboxView)
                    }
                    .onAppear() {
                        getMessageCount()
                    }
                Spacer()
                iPhoneHomeButton(title: "Search", imageName: "glyphicons-basic-28-search", buttonBackground: Color("HomeButtonSearch"))
                    .onTapGesture(count: 1) {
                        navigateTo(&appService.showingSearchView)
                    }
                Spacer()
                iPhoneHomeButton(title: "Tags", imageName: "glyphicons-basic-67-tags", buttonBackground: Color("HomeButtonTags"))
                    .onTapGesture(count: 1) {
                        navigateTo(&appService.showingTagsView)
                    }
            }
            .padding(.horizontal, 15)
            
            Spacer()
            
            // Home Screen Navigation
            VStack {
                // go to chat
                NavigationLink(destination: ChatView(), isActive: $appService.showingChatView) {
                    EmptyView()
                }.isDetailLink(false)
                
                // go to inbox
                NavigationLink(destination: InboxView(), isActive: $appService.showingInboxView) {
                    EmptyView()
                }.isDetailLink(false)
                
                // go to search
                NavigationLink(destination: SearchView(), isActive: $appService.showingSearchView) {
                    EmptyView()
                }.isDetailLink(false)
                
                // go to tags
                NavigationLink(destination: TagsView(), isActive: $appService.showingTagsView) {
                    EmptyView()
                }.isDetailLink(false)
                
                // go to settings
                NavigationLink(destination: SettingsView(), isActive: $appService.showingSettingsView) {
                    EmptyView()
                }.isDetailLink(false)
            }
            
        }
    }
}
