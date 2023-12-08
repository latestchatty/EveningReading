//
//  iPhoneHomeButtons.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct iPhoneHomeButtons: View {
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
        VStack {
            Spacer().frame(height: 40)
            
            HStack(alignment: .top) {
                iPhoneHomeButton(title: "Chat", imageName: "glyphicons-basic-238-chat-message", buttonBackground: Color("HomeButtonChat"))
                    .onTapGesture(count: 1) {
                        chatStore.getChat() // Refresh the chat
                        navigateTo(&appSessionStore.showingChatView)
                    }
                Spacer()
                iPhoneHomeButton(title: "Inbox", imageName: "glyphicons-basic-122-envelope-empty", buttonBackground: Color("HomeButtonInbox"))
                    .overlay(NewMessageBadgeView(notificationNumber: self.$messageStore.messageCount.unread), alignment: .top)
                    .onTapGesture(count: 1) {
                        navigateTo(&appSessionStore.showingInboxView)
                    }
                    .onAppear() {
                        getMessageCount()
                    }
                Spacer()
                iPhoneHomeButton(title: "Search", imageName: "glyphicons-basic-28-search", buttonBackground: Color("HomeButtonSearch"))
                    .onTapGesture(count: 1) {
                        navigateTo(&appSessionStore.showingSearchView)
                    }
                Spacer()
                iPhoneHomeButton(title: "Tags", imageName: "glyphicons-basic-67-tags", buttonBackground: Color("HomeButtonTags"))
                    .onTapGesture(count: 1) {
                        navigateTo(&appSessionStore.showingTagsView)
                    }
            }
            .padding(.horizontal, 15)
            
            Spacer()
            
            // Home Screen Navigation
            VStack {
                // go to chat
                NavigationLink(destination: ChatView(), isActive: $appSessionStore.showingChatView) {
                    EmptyView()
                }.isDetailLink(false)
                
                // go to inbox
                NavigationLink(destination: InboxView(), isActive: $appSessionStore.showingInboxView) {
                    EmptyView()
                }.isDetailLink(false)
                
                // go to search
                NavigationLink(destination: SearchView(populateTerms: .constant(""), populateAuthor: .constant(""), populateParent: .constant("")), isActive: $appSessionStore.showingSearchView) {
                    EmptyView()
                }.isDetailLink(false)
                
                // go to tags
                NavigationLink(destination: TagsView(), isActive: $appSessionStore.showingTagsView) {
                    EmptyView()
                }.isDetailLink(false)
                
                // go to settings
                NavigationLink(destination: SettingsView(), isActive: $appSessionStore.showingSettingsView) {
                    EmptyView()
                }.isDetailLink(false)
            }
            
        }
    }
}
