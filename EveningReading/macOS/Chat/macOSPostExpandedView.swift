//
//  macOSPostExpandedView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/10/21.
//

import SwiftUI

struct macOSPostExpandedView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    @Binding var postId: Int
    @Binding var postAuthor: String
    @Binding var replyLines: String?
    @Binding var lols: [ChatLols]
    @Binding var postText: [RichTextBlock]
    @Binding var postDateTime: String
    @Binding var op: String
    
    var body: some View {
        HStack {
            // Reply lines
            Text(self.replyLines == nil ? String(repeating: " ", count: 5) : self.replyLines!)
                .lineLimit(1)
                .fixedSize()
                .font(.custom("replylines", size: 25, relativeTo: .callout))
                .foregroundColor(Color("replyLines"))
            
            // Author
            AuthorNameView(name: self.postAuthor, postId: self.postId, op: self.op)
            
            Spacer()
            
            // Lols
            LolView(lols: self.lols, expanded: true, postId: self.postId)
        }
        HStack {
            VStack (alignment: .leading) {
                // Full post
                RichTextView(topBlocks: appSessionStore.blockedAuthors.contains(self.postAuthor) ? RichTextBuilder.getRichText(postBody: "[blocked]") : self.postText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(8)
                    .textSelection(.enabled)

                if appSessionStore.isSignedIn && !appSessionStore.blockedAuthors.contains(self.postAuthor) {
                    HStack {
                        Text(postDateTime.postTimestamp())
                            .font(.caption)
                            .foregroundColor(Color("NoDataLabel"))
                        Spacer()
                        macOSPostActionsView(name: self.postAuthor, postId: self.postId, showingHideThread: false)
                        macOSTagPostButton(postId: self.postId)
                        Image(systemName: "link")
                            .imageScale(.large)
                            .onTapGesture(count: 1) {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString("https://www.shacknews.com/chatty?id=\(self.postId)#item_\(self.postId)", forType: .URL)
                                chatStore.didCopyLink = true
                            }
                        Image(systemName: "arrowshape.turn.up.left")
                            .imageScale(.large)
                            .onTapGesture(count: 1) {
                                chatStore.newPostParentId = self.postId
                                chatStore.newReplyAuthorName = self.postAuthor
                                chatStore.showingNewPostSheet = true
                            }
                    }
                    .padding(.bottom, 8)
                    .padding(.horizontal, 8)
                } else {
                    HStack {
                        Text(postDateTime.postTimestamp())
                            .font(.caption)
                            .foregroundColor(Color("NoDataLabel"))
                        Spacer()
                        macOSPostActionsView(name: self.postAuthor, postId: self.postId, showingHideThread: false)
                    }
                    .padding(.bottom, 8)
                    .padding(.horizontal, 8)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color("ThreadBubblePrimary"))
        .cornerRadius(5)
    }
}

struct macOSPostExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        macOSPostExpandedView(postId: .constant(0), postAuthor: .constant(""), replyLines: .constant(""), lols: .constant([ChatLols]()), postText: .constant([RichTextBlock]()), postDateTime: .constant("2020-04-20T09:20:00Z"), op: .constant(""))
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
