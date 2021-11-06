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
    @EnvironmentObject var viewedPostsStore: ViewedPostsStore
    
    @Binding var threadId: Int
    
    @State private var rootPostCategory: String = "ontopic"
    @State private var rootPostAuthor: String = ""
    @State private var rootPostAuthorType: AuthorType = .none
    @State private var rootPostBody: String = ""
    @State private var rootPostRichText = [RichTextBlock]()
    @State private var rootPostDate: String = "2020-08-14T21:05:00Z"
    @State private var rootPostLols: [ChatLols] = [ChatLols]()
    
    @State private var postList = [ChatPosts]()
    @State private var postStrength = [Int: Double]()
    @State private var replyLines = [Int: String]()
    
    @State private var selectedPost = 0
    @State private var selectedPostRichText = [RichTextBlock]()
    @State private var showRootReply = false
    @State private var canRefresh = true
    @State private var isGettingThread = false
    @State private var selectedIndex: Int = 0
    @State private var showReportPost: Bool = false
    
    private func getThreadData() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
                if let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first {
                    self.rootPostCategory = rootPost.category
                    self.rootPostAuthor = rootPost.author
                    self.rootPostAuthorType = rootPost.authorType
                    self.rootPostBody = rootPost.body
                    self.rootPostRichText = RichTextBuilder.getRichText(postBody: rootPost.body)
                    self.rootPostDate = rootPost.date
                    self.rootPostLols = rootPost.lols
                }
            }
        } else {
            let threads = chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
            
            if let thread = threads.filter({ return $0.threadId == self.threadId }).first {
                if let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first {
                    self.rootPostCategory = rootPost.category
                    self.rootPostAuthor = rootPost.author
                    self.rootPostAuthorType = rootPost.authorType
                    self.rootPostBody = rootPost.body
                    self.rootPostRichText = RichTextBuilder.getRichText(postBody: rootPost.body)
                    self.rootPostDate = rootPost.date
                    self.rootPostLols = rootPost.lols
                }
            }
        }
    }
    
    private func getPostList(thread: ChatThread, parentId: Int) {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            // Replies to post
            let replies = thread.posts.filter({ return $0.parentId == parentId }).sorted(by: { $0.id < $1.id })
            
            // Font strength for recent posts
            postStrength = PostDecorator.getPostStrength(thread: thread)
            
            // Get replies to this post
            for post in replies {
                self.replyLines[post.id] = ReplyLineBuilder.getLines(post: post, thread: thread)
                postList.append(post)
                getPostList(thread: thread, parentId: post.id)
            }
        } else {
            // Replies to post
            let replies = thread.posts.filter({ return $0.parentId == parentId }).sorted(by: { $0.id < $1.id })
            
            // Font strength for recent posts
            postStrength = PostDecorator.getPostStrength(thread: thread)
            
            // Get replies to this post
            for post in replies {
                self.replyLines[post.id] = ReplyLineBuilder.getLines(post: post, thread: thread)
                postList.append(post)
                getPostList(thread: thread, parentId: post.id)
            }
        }
    }
    
    private func selectNextPost(forward: Bool = true) {
        if forward {
            self.selectedIndex = self.selectedIndex + 1
            if self.selectedIndex > self.postList.count {
                self.selectedIndex = 0
            }
        } else {
            self.selectedIndex = self.selectedIndex - 1
            if self.selectedIndex == -1 {
                self.selectedIndex = self.postList.count
            }
        }
        if self.selectedIndex == 0 {
            self.selectedPost = 0
        } else {
            self.selectedPost = self.postList[selectedIndex - 1].id
        }
        chatStore.activePostId = self.selectedPost
    }
    
    private func markThreadRead(_ handler: @escaping (Error?) -> Void) {
        var threadIds = self.postList.map({$0.id})
        threadIds.append(self.threadId)
        self.viewedPostsStore.markPostsViewed(postIds: threadIds, handler)
    }
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollProxy in
//                VStack {
//                    Spacer().frame(width: 0, height: 0)
//                }.id(999999991)
                VStack (alignment: .leading) {
                    if chatStore.activeThreadId == 0 {
                        HStack() {
                            Spacer()
                            Text("No thread selected.")
                                .font(.body)
                                .bold()
                                .foregroundColor(Color("NoDataLabel"))
                            Spacer()
                        }
                        .padding(.top, 10)
                    } else if !self.isGettingThread {
                        // Root post
                        macOSPostExpandedView(postId: self.$threadId, postAuthor: self.$rootPostAuthor, postAuthorType: self.$rootPostAuthorType, replyLines: .constant(""), lols: self.$rootPostLols, postText: self.$rootPostRichText, postDate: self.$rootPostDate, isRootPost: true)
                            .padding(.horizontal, 10)
                            .padding(.top, 10)
                        
                        // Replies
                        LazyVStack (alignment: .leading, spacing: 0) {
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
                                            macOSPostExpandedView(postId: .constant(post.id), postAuthor: .constant(post.author), postAuthorType: .constant(post.authorType), replyLines: self.$replyLines[post.id], lols: .constant(post.lols), postText: self.$selectedPostRichText, postDate: .constant(post.date))
                                        }
                                        .onAppear() {
                                            // Load Rich Text
                                            self.selectedPostRichText = RichTextBuilder.getRichText(postBody: post.body)
                                        }
                                    } else {
                                        // Reply preview row
                                        HStack {
                                            macOSPostPreviewView(postId: .constant(post.id), postAuthor: .constant(post.author), postAuthorType: .constant(post.authorType), replyLines: self.$replyLines[post.id], lols: .constant(post.lols), postPreviewText: .constant(post.preview), postCategory: .constant(post.category), postStrength: .constant(postStrength[post.id]))
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture(count: 1) {
                                            self.selectedPost = post.id
                                            self.selectedIndex = self.postList.firstIndex(where: {$0.id == post.id})! + 1
                                            self.chatStore.activePostId = post.id
                                        }
                                    }
                                    
                                }
                                .id(post.id)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    }
                }
                // Something about this causes a resource leak in instruments.
//                .onReceive(chatStore.$activeThreadId) { value in
//                    scrollProxy.scrollTo(999999991, anchor: .top)
//                }
                // This is a terrible experience
                // Scrolling needs to happen only if it needs to happen to make the post come into view.
                // Instead, no matter what anchor I use here it always scrolls which makes things fly all over the place if you're not just going top down/bottom up
//                .onReceive(chatStore.$activePostId, perform: { postId in
////                    DispatchQueue.main.asyncAfter(deadline: .now() + .miliseconds(200)) {
//                        withAnimation {
//                            scrollProxy.scrollTo(postId)
//                        }
////                    }
//                })
            }
        }
        
        .onReceive(chatStore.$activeThreadId) { value in
            self.isGettingThread = true
            self.selectedIndex = 0
            postList = [ChatPosts]()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                var tx = Transaction()
                tx.disablesAnimations = true
                withTransaction(tx) {
                    getThreadData()
                    postStrength = [Int: Double]()
                    replyLines = [Int: String]()
                    if let thread = chatStore.threads.filter({ return $0.threadId == self.threadId }).first {
                        getPostList(thread: thread, parentId: self.threadId)
                    }
                    self.isGettingThread = false
                }
            }
        }
        .onReceive(self.chatStore.$submitPostSuccessMessage) { successMessage in
            if successMessage == "" { return }
            
            DispatchQueue.main.async {
                self.chatStore.submitPostSuccessMessage = ""
                self.chatStore.submitPostErrorMessage = ""
                showRootReply = false
                DispatchQueue.main.asyncAfterPostDelay {
                    self.chatStore.getThread(viewedPostsStore: viewedPostsStore)
                }
            }
        }
        // If refreshing thread after posting
        .onReceive(chatStore.$didGetThreadStart) { value in
            if value && self.chatStore.didSubmitPost && chatStore.activeThreadId == self.threadId {
                chatStore.didGetThreadStart = false
                self.selectedPost = 0
                self.chatStore.activePostId = 0
                self.isGettingThread = true
            }
        }
        .onReceive(chatStore.$didGetThreadFinish) { value in
            if value && chatStore.activeThreadId == self.threadId && canRefresh {
                self.canRefresh = false
                self.chatStore.didSubmitPost = false
                self.chatStore.didGetThreadStart = false
                self.chatStore.didGetThreadFinish = false
                self.selectedPost = 0
                getThreadData()
                self.postList = [ChatPosts]()
                self.postStrength = [Int: Double]()
                if let thread = chatStore.threads.filter({ return $0.threadId == self.threadId }).first {
                    getPostList(thread: thread, parentId: self.threadId)
                }
                self.isGettingThread = false
                self.canRefresh = true
            }
        }
        .overlay(LoadingView(show: self.$isGettingThread, title: .constant("")))
        .toolbar {
            // I want to make this conditional on whether a thread is selected or not but when I do this, it seems to crash the compiler.
            // if chatStore.activeThread != 0 {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    self.markThreadRead() { _ in
                        self.chatStore.getThread(viewedPostsStore: viewedPostsStore)
                    }
                }, label: {
                    Image(systemName: "arrow.counterclockwise")
                        .imageScale(.large)
                })
                .buttonStyle(BorderlessButtonStyle())
                .help("Refresh thread")
                
                Button(action: {
                    self.markThreadRead() { _ in }
                }, label: {
                    Image(systemName: "envelope.open")
                        .imageScale(.large)
                })
                .buttonStyle(BorderlessButtonStyle())
                .help("Mark all posts in thread read")
                .keyboardShortcut("m", modifiers:[.command, .shift])
                
                Spacer()
                
                Button(action: {
                    self.selectNextPost(forward: false)
                }, label: {
                    Image(systemName: "arrowtriangle.backward")
                        .imageScale(.large)
                })
                .buttonStyle(BorderlessButtonStyle())
                .help("Select previous post")
                .keyboardShortcut("a", modifiers: [.command, .shift])
                
                Button(action: {
                    self.selectNextPost()
                }, label: {
                    Image(systemName: "arrowtriangle.forward")
                        .imageScale(.large)
                })
                .buttonStyle(BorderlessButtonStyle())
                .help("Select next post")
                .keyboardShortcut("z", modifiers: [.command, .shift])
                
            }
            //  } else {
            //    EmptyView()
            //}
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
