//
//  HomeButtons.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct HomeButtons: View {
    @EnvironmentObject var appSessionStore: AppSessionStore

    func navigateTo(_ goToDestination: inout Bool) {
        appSessionStore.resetNavigation()
        goToDestination = true
    }
    
    var body: some View {
        VStack {
            Spacer().frame(height: 40)
            HStack(alignment: .top) {
                HomeButton(title: "Chat", imageName: "glyphicons-basic-238-chat-message", buttonBackground: Color("HomeButtonChat"))
                .onTapGesture(count: 1) {
                    navigateTo(&appSessionStore.showingChatView)
                }
                Spacer()
                HomeButton(title: "Inbox", imageName: "glyphicons-basic-122-envelope-empty", buttonBackground: Color("HomeButtonInbox"))
                .onTapGesture(count: 1) {
                    navigateTo(&appSessionStore.showingMessagesView)
                }
                Spacer()
                HomeButton(title: "Search", imageName: "glyphicons-basic-28-search", buttonBackground: Color("HomeButtonSearch"))
                .onTapGesture(count: 1) {
                    navigateTo(&appSessionStore.showingSearchView)
                }
                Spacer()
                HomeButton(title: "Tags", imageName: "glyphicons-basic-67-tags", buttonBackground: Color("HomeButtonTags"))
                .onTapGesture(count: 1) {
                    navigateTo(&appSessionStore.showingTagsView)
                }
            }
            .padding(.horizontal, 15)
            Spacer()
        }
    }
}

struct HomeButtons_Previews: PreviewProvider {
    static var previews: some View {
        HomeButtons()
    }
}
