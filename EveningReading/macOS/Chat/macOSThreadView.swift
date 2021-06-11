//
//  macOSThreadView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/11/21.
//

import SwiftUI

struct macOSThreadView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    @Binding var threadId: Int
    
    @State private var rootPostCategory: String = "ontopic"
    @State private var rootPostAuthor: String = ""
    @State private var rootPostBody: String = ""
    @State private var rootPostRichText = [RichTextBlock]()
    @State private var rootPostDate: String = "2020-08-14T21:05:00Z"
    @State private var rootPostLols: [ChatLols] = [ChatLols]()
    @State private var contributed: Bool = false
    @State private var replyCount: Int = 0
    
    @State private var postList = [ChatPosts]()
    @State private var postStrength = [Int: Double]()
    @State private var replyLines = [Int: String]()
    
    @State private var selectedPost = 0
    @State private var selectedPostRichText = [RichTextBlock]()
    
    private func getThreadData() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
                if let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first {
                    self.rootPostCategory = rootPost.category
                    self.rootPostAuthor = rootPost.author
                    self.rootPostBody = rootPost.body
                    self.rootPostRichText = RichTextBuilder.getRichText(postBody: rootPost.body)
                    self.rootPostDate = rootPost.date
                    self.rootPostLols = rootPost.lols
                }
                self.replyCount = thread.posts.count - 1
                
            }
        } else {
            let threads = chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
            
            if let thread = threads.filter({ return $0.threadId == self.threadId }).first {
                self.contributed = PostDecorator.checkParticipatedStatus(thread: thread, author: self.rootPostAuthor)
                if let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first {
                    self.rootPostCategory = rootPost.category
                    self.rootPostAuthor = rootPost.author
                    self.rootPostBody = rootPost.body
                    self.rootPostRichText = RichTextBuilder.getRichText(postBody: rootPost.body)
                    self.rootPostDate = rootPost.date
                    self.rootPostLols = rootPost.lols
                }
                self.replyCount = thread.posts.count - 1
            }
        }
    }
    
    private func getPostList(parentId: Int) {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
                {
            if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
                // Replies to post
                let replies = thread.posts.filter({ return $0.parentId == parentId }).sorted(by: { $0.id < $1.id })
                
                // Font strength for recent posts
                postStrength = PostDecorator.getPostStrength(thread: thread)
                
                // Get replies to this post
                for post in replies {
                    self.replyLines[post.id] = ReplyLineBuilder.getLines(post: post, thread: thread)
                    postList.append(post)
                    getPostList(parentId: post.id)
                }
            }
        } else {
            if let thread = chatStore.threads.filter({ return $0.threadId == self.threadId }).first {
                // Replies to post
                let replies = thread.posts.filter({ return $0.parentId == parentId }).sorted(by: { $0.id < $1.id })
                
                // Font strength for recent posts
                postStrength = PostDecorator.getPostStrength(thread: thread)
                
                // Get replies to this post
                for post in replies {
                    self.replyLines[post.id] = ReplyLineBuilder.getLines(post: post, thread: thread)
                    postList.append(post)
                    getPostList(parentId: post.id)
                }
            }
        }
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            
            // Root post
            VStack (alignment: .leading) {
                HStack {
                    AuthorNameView(name: self.rootPostAuthor, postId: self.threadId, bold: true)
                    
                    ContributedView(contributed: self.contributed)
                    
                    LolView(lols: self.rootPostLols, capsule: true, postId: self.threadId)

                    Spacer()

                    ReplyCountView(replyCount: self.replyCount)
                    
                    /*
                    Text(self.rootPostDate.getTimeAgo())
                        .foregroundColor(Color.gray)
                        .font(.body)
                    */
                    
                    Image(systemName: "eye.slash")
                        .imageScale(.large)
                        .onTapGesture(count: 1) {
                        }
                    
                    if appSessionStore.isSignedIn {
                        Image(systemName: "tag")
                            .imageScale(.large)
                            .onTapGesture(count: 1) {
                            }
                    
                        Image(systemName: "arrowshape.turn.up.left")
                            .imageScale(.large)
                            .onTapGesture(count: 1) {
                            }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)
                
                // Root post body
                VStack (alignment: .leading) {
                    RichTextView(topBlocks: self.rootPostRichText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity)
            .background(Color("ThreadBubblePrimary"))
            .cornerRadius(10)
            .padding(.horizontal, 10)
            
            // Replies
            VStack {
                ForEach(postList, id: \.id) { post in
                    HStack {
                        
                        // Reply expaned row
                        if self.selectedPost == post.id {
                            VStack {
                                macOSPostExpandedView(postId: .constant(post.id), postAuthor: .constant(post.author), replyLines: self.$replyLines[post.id], lols: .constant(post.lols), postText: self.$selectedPostRichText)
                            }
                            .onAppear() {
                                // Load Rich Text
                                self.selectedPostRichText = RichTextBuilder.getRichText(postBody: post.body)
                            }
                        }
                        
                        // Reply preview row
                        if self.selectedPost != post.id {
                            HStack {
                                macOSPostPreviewView(postId: .constant(post.id), postAuthor: .constant(post.author), replyLines: self.$replyLines[post.id], lols: .constant(post.lols), postText: .constant(post.body), postCategory: .constant(post.category), postStrength: .constant(postStrength[post.id]))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture(count: 1) {
                                //withAnimation {
                                    selectedPost = post.id
                                //}
                            }
                        }
                        
                    }
                    .id(post.id)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            
            
        }
        .onReceive(chatStore.$activeThreadId) { value in
            getThreadData()
            postList = [ChatPosts]()
            postStrength = [Int: Double]()
            replyLines = [Int: String]()
            getPostList(parentId: self.threadId)
        }
    }
}

struct macOSThreadView_Previews: PreviewProvider {
    static var previews: some View {
        macOSThreadView(threadId: .constant(999999992))
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
