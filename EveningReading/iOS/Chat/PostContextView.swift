//
//  PostContextView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/9/21.
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

struct PostContextView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var messageStore: MessageStore
    
    @Binding var showingWhosTaggingView: Bool
    @Binding var showingNewMessageView: Bool

    @Binding var messageRecipient: String
    @Binding var messageSubject: String
    @Binding var messageBody: String
    
    @Binding var collapsed: Bool
    
    var author: String = ""
    var postId: Int = 0
    var threadId: Int = 0
    var isRootPost: Bool = false
    var postBody: String = ""
    var showCopyPost: Bool = false
    
    var body: some View {
        Button(action: {
            chatStore.activePostId = postId
            self.showingWhosTaggingView = true
        }) {
            Text("Who's Tagging?")
            Image(systemName: "tag.circle")
        }
        
        if self.threadId > 0 && !self.isRootPost {
            Button(action: {
                self.collapsed = true
                appSessionStore.collapsedThreads.append(self.threadId)
            }) {
                Text("Hide Thread")
                Image(systemName: "eye.slash")
            }
        }
        
        Button(action: {
            self.messageRecipient = self.author
            self.messageSubject = " "
            self.messageBody = " "
            self.showingNewMessageView = true
        }) {
            Text("Message User")
            Image(systemName: "envelope.circle")
        }
        
        if showCopyPost {
            Button(action: {
                chatStore.copyPostText = self.postBody
                chatStore.showingCopyPostSheet = true
            }) {
                Text("Copy Post")
                Image(systemName: "doc.on.doc")
            }
        }
        
        /*
        Button(action: {
            print("button")
        }) {
            Text("Search Author")
            Image(systemName: "magnifyingglass.circle")
        }
        */
        
        Button(action: {
            let shackURL = "https://www.shacknews.com/chatty?id=\(self.postId)#item_\(self.postId)"
            let board = UIPasteboard.general
            board.string = shackURL
            chatStore.showingCopiedNotice = true
            /*
            UIPasteboard.general.setValue(shackURL,
                        forPasteboardType: kUTTypePlainText as String)
            */
        }) {
            Text("Copy Link")
            Image(systemName: "doc.on.clipboard")
        }
        
        if !appSessionStore.favoriteAuthors.contains(self.author) {
            Button(action: {
                appSessionStore.favoriteAuthors.append(self.author)
                chatStore.showingFavoriteNotice = true
            }) {
                Text("Favorite User")
                Image(systemName: "star")
            }
        }
        
        Button(action: {
            appSessionStore.blockedAuthors.append(self.author)
        }) {
            Text("Block User")
            Image(systemName: "exclamationmark.circle")
        }
        
        Button(action: {
            self.messageRecipient = "Duke Nuked"
            self.messageSubject = "Reporting Author of Post"
            self.messageBody = messageStore.getComplaintText(author: self.author, postId: self.postId)
            self.showingNewMessageView = true
        }) {
            Text("Report User")
            Image(systemName: "exclamationmark.circle")
        }
        .onAppear() {
            chatStore.activePostId = self.postId
        }
        
    }
}
