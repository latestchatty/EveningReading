//
//  watchOSPostDetail.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct watchOSPostDetail: View {
    @EnvironmentObject var appSession: AppSession
    @EnvironmentObject var chatStore: ChatStore
    
    @Binding var postId: Int
    
    @State private var postCategory: String = "ontopic"
    @State private var postAuthor: String = ""
    @State private var contributed: Bool = false
    @State private var postBody: String = ""
    @State private var richTextBody = [RichTextBlock]()
    @State private var postDate: String = "2020-08-14T21:05:00Z"
    @State private var postLols: [ChatLols] = [ChatLols]()
    @State private var replies: [ChatPosts] = [ChatPosts]()
    
    @State private var isRootPost: Bool = false
    
    private func getThreadData() {
        let thread = chatStore.threads.filter { !$0.posts.isEmpty && $0.posts.contains(where: { post in post.id == self.postId }) }.first
        setThreadData(thread)
    }
    
    private func setThreadData(_ thread: ChatThread?) {
        if let childPost = thread?.posts.filter({ return $0.id == self.postId }).first {
            self.postCategory = childPost.category
            self.postAuthor = childPost.author
            self.postBody = childPost.body
            self.postDate = childPost.date
            self.postLols = childPost.lols
            self.replies = thread?.posts.filter({ return $0.parentId == self.postId }) ?? [ChatPosts]()
            
            if appSession.blockedAuthors.contains(self.postAuthor) {
                self.richTextBody = RichTextBuilder.getRichText(postBody: "[blocked]")
            } else {
                self.richTextBody = RichTextBuilder.getRichText(postBody: self.postBody)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            
            // Fixes navigation bug
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.frame(width: 0, height: 0)
            
            LazyVStack {
                
                // Post
                VStack (alignment: .leading) {
                    HStack {
                        AuthorNameView(name: appSession.blockedAuthors.contains(self.postAuthor) ? "[blocked]" : self.postAuthor, postId: self.postId)
                        ContributedView(contributed: self.contributed)
                        Spacer()
                        LolView(lols: self.postLols, postId: self.postId)
                    }
                    .padding(.bottom, 2)
                    
                    HStack {
                        RichTextView(topBlocks: self.richTextBody)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
                .background(Color("ThreadBubblePrimary"))
                .cornerRadius(5)
                
                // Replies
                if self.replies.count > 0 {
                    ForEach(self.replies, id: \.id) { reply in
                        watchOSPostPreview(postId: .constant(reply.id), replyText: .constant(String(reply.body.getPreview.prefix(100))), author: .constant(reply.author))
                            .environmentObject(appSession)
                            .environmentObject(chatStore)
                    }
                } else {
                    EmptyView()
                }
                
            }
            
        }
        .onAppear(perform: getThreadData)
    }
}
