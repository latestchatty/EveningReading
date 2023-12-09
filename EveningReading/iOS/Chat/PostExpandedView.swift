//
//  PostExpandedView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/12/21.
//

import SwiftUI

struct PostExpandedView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    var username: String
    var postId: Int
    var postBody: String
    var replyLines: String
    var postCategory: String
    var postStrength: Double?
    var postAuthor: String
    var postLols: [ChatLols]
    var postRichText = [RichTextBlock]()
    var postDateTime: String
    var op: String = ""

    var body: some View {
        VStack {
            HStack {
                // Reply lines
                HStack(spacing: 0) {
                    ForEach(Array(self.replyLines.enumerated()), id: \.offset) { index, character in
                        Text(String(character))
                            .lineLimit(1)
                            .fixedSize()
                            .font(.custom("replylines", size: 25, relativeTo: .callout))
                            .foregroundColor(Color("replyLines"))
                            .overlay(
                                Text(
                                    self.postId == chatStore.activePostId && self.replyLines.count - 1 == index && index > 0 ? String(character) : ""
                                )
                                    .lineLimit(1)
                                    .fixedSize()
                                    .font(.custom("replylines", size: 25, relativeTo: .callout))
                                    .foregroundColor(Color.red)
                            )
                    }
                }
                
                // Author name
                AuthorNameView(name: appSessionStore.blockedAuthors.contains(self.postAuthor) ? "[blocked]" : self.postAuthor, postId: self.postId, op: self.op)
                
                Spacer()
                
                // Tags/Lols
                LolView(lols: self.postLols, expanded: true, postId: self.postId)
            }
            VStack {
                // Post body
                if appSessionStore.blockedAuthors.contains(self.postAuthor) {
                    HStack {
                        Text("[blocked]")
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                } else {
                    HStack {
                        RichTextView(topBlocks: self.postRichText)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                }
                
                // Tag and reply
                if appSessionStore.isSignedIn {
                    HStack {
                        Text(postDateTime.postTimestamp())
                            .font(.caption)
                            .foregroundColor(Color("NoDataLabel"))
                        Spacer()
                        TagPostView(postId: self.postId)
                        Spacer().frame(width: 10)
                        ComposePostView(postId: self.postId, replyToPostBody: self.postBody, replyToAuthor: self.postAuthor)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                }
            }
            .background(RoundedCornersView(color: Color("ChatBubbleSecondary")))
            .padding(.bottom, 5)
        }
    }
}
