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

    var body: some View {
        VStack {
            HStack {
                // Reply lines
                Text(self.replyLines)
                    .lineLimit(1)
                    .fixedSize()
                    .font(.custom("replylines", size: 25, relativeTo: .callout))
                    .foregroundColor(Color("replyLines"))
                
                // Author name
                AuthorNameView(name: appSessionStore.blockedAuthors.contains(self.postAuthor) ? "[blocked]" : self.postAuthor, postId: self.postId)
                
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
                        Text(postDateTime.fromISO8601())
                            .font(.caption)
                            .foregroundColor(Color("NoDataLabel"))
                        Spacer()
                        TagPostView(postId: self.postId)
                        Spacer().frame(width: 10)
                        ComposePostView(postId: self.postId)
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

struct PostExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        PostExpandedView(username: "aenean", postId: 0, postBody: "This is a post.", replyLines: "A", postCategory: "ontopic", postStrength: 0.75, postAuthor: "aenean", postLols: [ChatLols](), postRichText: [RichTextBlock](), postDateTime: "2020-08-14T21:05:00Z")
        .environment(\.colorScheme, .dark)
        .environmentObject(AppSessionStore(service: AuthService()))
    }
}
