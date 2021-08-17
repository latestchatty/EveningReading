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
    @State private var showRootReply = false
    
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
    
    private func selectNextPost(forward: Bool = true) {
        let selectedIndex = self.postList.firstIndex { $0.id == self.selectedPost }
        
        if forward {
            if selectedIndex == nil {
                self.selectedPost = self.postList.first?.id ?? 0
            } else if selectedIndex == (self.postList.count - 1) {
                self.selectedPost = 0
            } else {
                self.selectedPost = self.postList[selectedIndex! + 1].id
            }
        } else {
            if selectedIndex == nil {
                self.selectedPost = self.postList.last?.id ?? 0
            } else if selectedIndex == 0 {
                self.selectedPost = 0
            } else {
                self.selectedPost = self.postList[selectedIndex! - 1].id
            }
        }
    }
    
    var body: some View {
        //Throwing error about "each layout item may only occur once" when switching to LazyVStack.
        // It only happens occasionally. Seemingly after A/Zing through posts quickly
        // then switching to a different thread...
        LazyVStack (alignment: .leading, pinnedViews: .sectionHeaders) {
            Section(header:
                        HStack() {
                            Spacer()
                            Button(action: {
                                self.selectNextPost(forward: false)
                            }, label: {
                                Image(systemName: "arrowtriangle.backward")
                                    .imageScale(.large)
                            })
                            .buttonStyle(BorderlessButtonStyle())
                            .keyboardShortcut("a", modifiers: [.command, .shift])
                            
                            Button(action: {
                                self.selectNextPost()
                            }, label: {
                                Image(systemName: "arrowtriangle.forward")
                                    .imageScale(.large)
                            })
                            .buttonStyle(BorderlessButtonStyle())
                            .keyboardShortcut("z", modifiers: [.command, .shift])
                        }
                        .padding(8)
                        .background(Color("PrimaryBackground"))
            ) {
                // Root post
                VStack (alignment: .leading) {
                    HStack {
                        AuthorNameView(name: self.rootPostAuthor, postId: self.threadId)
                        
                        ContributedView(contributed: self.contributed)
                        
                        Spacer()
                        
                        LolView(lols: self.rootPostLols, expanded: true, postId: self.threadId)
                        
                        ReplyCountView(replyCount: self.replyCount)
                        
                        /*
                         Text(self.rootPostDate.getTimeAgo())
                         .foregroundColor(Color.gray)
                         .font(.body)
                         */
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    
                    // Root post body
                    VStack (alignment: .leading) {
                        RichTextView(topBlocks: self.rootPostRichText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
                    if appSessionStore.isSignedIn {
                        HStack {
                            Spacer()
                            Button(action: {}, label: {
                                Image(systemName: "tag")
                                    .imageScale(.large)
                            })
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Button(action: {
                                showRootReply = !showRootReply
                            }, label: {
                                Image(systemName: "arrowshape.turn.up.left")
                                    .imageScale(.large)
                                    .foregroundColor(showRootReply ? Color.accentColor : Color.primary)
                            })
                            .buttonStyle(BorderlessButtonStyle())
                            .keyboardShortcut("r", modifiers: [.command, .option])
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, showRootReply ? 8 : 10)
                        if (showRootReply) {
                            macOSComposeView(postId: self.threadId)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 10)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color("ThreadBubblePrimary"))
                .cornerRadius(10)
                .padding(.horizontal, 10)
                
                // Replies
                VStack {
                    // No replies yet
                    if postList.count < 1 {
                        HStack {
                            Spacer()
                            Text("No replies, be the first to post.")
                                .font(.body)
                                .bold()
                                .foregroundColor(Color("NoDataLabel"))
                            Spacer()
                        }
                    }
                    
                    // Post list
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
                            } else {
                                // Reply preview row
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
            .onReceive(self.chatStore.$submitPostSuccessMessage) { successMessage in
                DispatchQueue.main.async {
                    showRootReply = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        self.chatStore.getThread()
                    }
                }
            }
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
