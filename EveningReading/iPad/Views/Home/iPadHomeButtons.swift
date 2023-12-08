//
//  iPadHomeButtons.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct iPadHomeButtons: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var messageStore: MessageStore
    
    private func navigateTo(_ goToDestination: inout Bool) {
        appSessionStore.resetNavigation()
        goToDestination = true
    }
    
    private func getMessageCount() {
        messageStore.getCount()
    }

    var body: some View {
        HStack() {
            Spacer().frame(width: 20)
            
            iPadHomeButton(title: "Chat", imageName: "glyphicons-basic-238-chat-message", buttonBackground: Color("HomeButtonChat"))
                .onTapGesture(count: 1) {
                    chatStore.activeThreadId = 0 // Deselect any threads
                    chatStore.getChat() // Refresh the chat
                    navigateTo(&appSessionStore.showingChatView)
                }
            
            GeometryReader { geometry in
                iPadHomeButton(title: "Inbox", imageName: "glyphicons-basic-122-envelope-empty", buttonBackground: Color("HomeButtonInbox"))
                    .overlay(NewMessageBadgeView(notificationNumber: self.$messageStore.messageCount.unread, width: geometry.size.width), alignment: .top)
                    .onTapGesture(count: 1) {
                        navigateTo(&appSessionStore.showingInboxView)
                    }
                    .onAppear() {
                        getMessageCount()
                    }
            }
            iPadHomeButton(title: "Search", imageName: "glyphicons-basic-28-search", buttonBackground: Color("HomeButtonSearch"))
                .onTapGesture(count: 1) {
                    navigateTo(&appSessionStore.showingSearchView)
                }
            
            iPadHomeButton(title: "Tags", imageName: "glyphicons-basic-67-tags", buttonBackground: Color("HomeButtonTags"))
                .onTapGesture(count: 1) {
                    navigateTo(&appSessionStore.showingTagsView)
                }
            
            Spacer().frame(width: 20)
            
            // Home Screen Navigation
            VStack {
                // go to chat
                NavigationLink(destination: iPadChatView(), isActive: $appSessionStore.showingChatView) {
                    EmptyView()
                }
                
                // go to inbox
                NavigationLink(destination: InboxView(), isActive: $appSessionStore.showingInboxView) {
                    EmptyView()
                }
                
                // go to search
                NavigationLink(destination: SearchView(populateTerms: .constant(""), populateAuthor: .constant(""), populateParent: .constant("")), isActive: $appSessionStore.showingSearchView) {
                    EmptyView()
                }
                
                // go to tags
                NavigationLink(destination: TagsView(), isActive: $appSessionStore.showingTagsView) {
                    EmptyView()
                }
                
                // go to settings
                NavigationLink(destination: SettingsView(), isActive: $appSessionStore.showingSettingsView) {
                    EmptyView()
                }
            }
            
        }
        .padding(.top, 10)
    }
}
