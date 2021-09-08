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
    @EnvironmentObject var viewedPostsStore: ViewedPostsStore
    
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
                iPhoneHomeButton(title: .constant("Chat"), imageName: .constant("glyphicons-basic-238-chat-message"), buttonBackground: .constant(Color("HomeButtonChat")))
                    .onTapGesture(count: 1) {
                        chatStore.getChat(viewedPostsStore: self.viewedPostsStore) // Refresh the chat
                        navigateTo(&appSessionStore.showingChatView)
                    }
                Spacer()
                iPhoneHomeButton(title: .constant("Inbox"), imageName: .constant("glyphicons-basic-122-envelope-empty"), buttonBackground: .constant(Color("HomeButtonInbox")))
                    .overlay(NewMessageBadgeView(notificationNumber: self.$messageStore.messageCount.unread), alignment: .top)
                    .onTapGesture(count: 1) {
                        navigateTo(&appSessionStore.showingInboxView)
                    }
                    .onAppear() {
                        getMessageCount()
                    }
                Spacer()
                iPhoneHomeButton(title: .constant("Search"), imageName: .constant("glyphicons-basic-28-search"), buttonBackground: .constant(Color("HomeButtonSearch")))
                    .onTapGesture(count: 1) {
                        navigateTo(&appSessionStore.showingSearchView)
                    }
                Spacer()
                iPhoneHomeButton(title: .constant("Tags"), imageName: .constant("glyphicons-basic-67-tags"), buttonBackground: .constant(Color("HomeButtonTags")))
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

struct iPhoneHomeButtons_Previews: PreviewProvider {
    static var previews: some View {
        iPhoneHomeButtons()
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
            .environmentObject(MessageStore(service: MessageService()))
    }
}
