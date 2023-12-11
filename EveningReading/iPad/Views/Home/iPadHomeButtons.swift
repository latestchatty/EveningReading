//
//  iPadHomeButtons.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct iPadHomeButtons: View {
    @EnvironmentObject var appSession: AppSession
    @EnvironmentObject var chatStore: ChatStore
    
    @StateObject var messageViewModel = MessageViewModel()
    
    private func navigateTo(_ goToDestination: inout Bool) {
        appSession.resetNavigation()
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
                    chatStore.activeThreadId = 0 // Deselect any threads
                    chatStore.getChat() // Refresh the chat
                    navigateTo(&appSession.showingChatView)
                }
            
            GeometryReader { geometry in
                iPadHomeButton(title: "Inbox", imageName: "glyphicons-basic-122-envelope-empty", buttonBackground: Color("HomeButtonInbox"))
                    .overlay(NewMessageBadgeView(notificationNumber: $messageViewModel.messageCount.unread, width: geometry.size.width), alignment: .top)
                    .onTapGesture(count: 1) {
                        navigateTo(&appSession.showingInboxView)
                    }
                    .onAppear() {
                        getMessageCount()
                    }
            }
            iPadHomeButton(title: "Search", imageName: "glyphicons-basic-28-search", buttonBackground: Color("HomeButtonSearch"))
                .onTapGesture(count: 1) {
                    navigateTo(&appSession.showingSearchView)
                }
            
            iPadHomeButton(title: "Tags", imageName: "glyphicons-basic-67-tags", buttonBackground: Color("HomeButtonTags"))
                .onTapGesture(count: 1) {
                    navigateTo(&appSession.showingTagsView)
                }
            
            Spacer().frame(width: 20)
            
            // Home Screen Navigation
            VStack {
                // go to chat
                NavigationLink(destination: iPadChatView(), isActive: $appSession.showingChatView) {
                    EmptyView()
                }
                
                // go to inbox
                NavigationLink(destination: InboxView(), isActive: $appSession.showingInboxView) {
                    EmptyView()
                }
                
                // go to search
                NavigationLink(destination: SearchView(populateTerms: .constant(""), populateAuthor: .constant(""), populateParent: .constant("")), isActive: $appSession.showingSearchView) {
                    EmptyView()
                }
                
                // go to tags
                NavigationLink(destination: TagsView(), isActive: $appSession.showingTagsView) {
                    EmptyView()
                }
                
                // go to settings
                NavigationLink(destination: SettingsView(), isActive: $appSession.showingSettingsView) {
                    EmptyView()
                }
            }
            
        }
        .padding(.top, 10)
    }
}
