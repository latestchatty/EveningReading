//
//  ThreadDetailView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

// NOTE: Comment line 218 to enable preview

struct ThreadDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
        
    @Binding var threadId: Int
    @Binding var postId: Int
    @Binding var replyCount: Int
    @Binding var isSearchResult: Bool
    
    @State private var loadingLimit = 100

    @State private var rootPostCategory: String = "ontopic"
    @State private var rootPostAuthor: String = ""
    @State private var rootPostBody: String = ""
    @State private var rootPostRichText = [RichTextBlock]()
    @State private var rootPostDate: String = "2020-08-14T21:05:00Z"
    @State private var rootPostLols: [ChatLols] = [ChatLols]()
    @State private var postCount: Int = 0
    @State private var contributed: Bool = false
    @State private var showThread: Bool = false
    
    @State private var postList = [ChatPosts]()
    @State private var postStrength = [Int: Double]()
    @State private var replyLines = [Int: String]()
    
    @State private var selectedPost = 0
    @State private var selectedPostRichText = [RichTextBlock]()
    
    @State private var username: String = ""
    
    @State private var isGettingThread: Bool = false
    
    @State private var showingWhosTaggingView = false
    
    @State private var showingNewMessageView = false
    @State private var messageRecipient: String = ""
    @State private var messageSubject: String = ""
    @State private var messageBody: String = ""
    
    @State private var collapsePost = false
    
    @State private var canRefresh = true
    
    @State private var threadNavigationLocation: CGPoint = CGPoint(x: UIScreen.main.bounds.width - 50, y: UIScreen.main.bounds.height - 120)

    // For highlighting
    private func getUserData() {
        let user: String? = KeychainWrapper.standard.string(forKey: "Username")
        self.username = user?.lowercased() ?? ""
    }
    
    // Get thread data from the appropriate source
    private func getThreadData() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            // Get thread data for previews
            if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
                setThreadData(thread)
                self.showThread = true
            } else {
                self.showThread = false
            }
        } else {
            // Get thread data for a linked/pushed post
            if self.postId > 0 {
                chatStore.getThreadByPost(postId: self.postId) {
                    if let thread = chatStore.searchedThreads.first {
                        setThreadData(thread)
                        postList.removeAll()
                        getPostList(parentId: self.threadId)
                        if let searchedPost = thread.posts.filter({ return $0.id == self.postId }).first {
                            self.selectedPostRichText = RichTextBuilder.getRichText(postBody: searchedPost.body)
                            self.selectedPost = self.postId
                            if self.postId != self.threadId {
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                                    self.chatStore.scrollTargetThread = self.postId
                                }
                            }
                        }
                        self.showThread = true
                    } else {
                        self.showThread = false
                    }
                }
            } else {
                // Get thread data from the chatty
                if let thread = chatStore.threads.filter({ return $0.threadId == self.threadId }).first {
                    setThreadData(thread)
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        chatStore.activeThreadId = thread.threadId
                    }
                    self.showThread = true
                } else {
                    self.showThread = false
                }
            }
        }
    }
    
    private func setThreadData(_ thread: ChatThread) {
        if let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first {
            self.rootPostCategory = rootPost.category
            self.rootPostAuthor = rootPost.author
            self.rootPostBody = rootPost.body
            self.rootPostRichText = RichTextBuilder.getRichText(postBody: self.rootPostBody)
            self.rootPostDate = rootPost.date.postTimestamp()
            self.rootPostLols = rootPost.lols
            self.postCount = thread.posts.count
        }
    }
    
    // Loop through posts and build reply lines & post strength
    private func getPostList(parentId: Int) {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
                {
            if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
                setPostData(thread: thread, parentId: parentId)
            }
        } else if self.postId > 0 {
            if let thread = chatStore.searchedThreads.first {
                setPostData(thread: thread, parentId: parentId)
            }
        } else {
            if let thread = chatStore.threads.filter({ return $0.threadId == self.threadId }).first {
                setPostData(thread: thread, parentId: parentId)
            }
        }
    }
    
    private func setPostData(thread: ChatThread, parentId: Int) {
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
    
    // Drag the thread navigation buttons
    private var threadNavigationDrag: some Gesture {
        DragGesture()
        .onChanged { value in
            self.threadNavigationLocation = value.location
        }
        .onEnded { value in
            self.appSessionStore.threadNavigationLocationX = self.threadNavigationLocation.x
            self.appSessionStore.threadNavigationLocationY = self.threadNavigationLocation.y
        }
    }

    // Page down through replies in thread
    private func showNextReply() {
        if postList.count > 0 {
            if self.selectedPost == 0 {
                setSelectedPost(0)
            } else {
                for i in 0..<self.postList.count {
                    if self.selectedPost == self.postList[i].id {
                        impact(style: .soft)
                        if i + 1 < self.postList.count {
                            setSelectedPost(i + 1)
                        } else {
                            setSelectedPost(0)
                        }
                        break
                    }
                }
            }
            self.chatStore.scrollTargetThread = self.selectedPost
        }
    }
    
    // Page up through replies in thread
    private func showPreviousReply() {
        if postList.count > 0 {
            if self.selectedPost == 0 {
                setSelectedPost(postList.count - 1)
            } else {
                for i in 0..<self.postList.count {
                    if self.selectedPost == self.postList[i].id {
                        impact(style: .soft)
                        if i - 1 > -1 {
                            setSelectedPost(i - 1)
                        } else {
                            setSelectedPost(postList.count - 1)
                        }
                        break
                    }
                }
            }
            self.chatStore.scrollTargetThread = self.selectedPost
        }
    }
    
    private func setSelectedPost(_ postIndex: Int) {
        self.selectedPostRichText = RichTextBuilder.getRichText(postBody: postList[postIndex].body)
        self.selectedPost = postList[postIndex].id
    }
    
    var body: some View {
        VStack {
            
            // Comment out to see preview (as well as overlay below)
            if UIDevice.current.userInterfaceIdiom == .phone {
                //GoToPostView(currentViewName: "ThreadView")
                GoToShackLinkView()
            }
            
            // This little bit of code might not be needed
            // since these both are navigation items (see
            // bottom of file)
            /*
            if UIDevice.current.userInterfaceIdiom == .pad {
                HStack {
                    WhosTaggingView(showingWhosTaggingView: self.$showingWhosTaggingView)
                    NewMessageView(showingNewMessageSheet: self.$showingNewMessageView, messageId: Binding.constant(0), recipientName: self.$messageRecipient, subjectText: self.$messageSubject, bodyText: self.$messageBody)
                }
            }
            */
            // End comment out to preview
            
            if self.showThread {
                
                
                // height: 20
                RefreshableScrollView(height: 70, refreshing: self.$chatStore.gettingThread, scrollTarget: self.$chatStore.scrollTargetThread, scrollTargetTop: self.$chatStore.scrollTargetThreadTop) {
                    
                    // Root Post
                    VStack {
                        // Post details
                        HStack (alignment: .center) {
                            AuthorNameView(name: appSessionStore.blockedAuthors.contains(self.rootPostAuthor) ? "[blocked]" : self.rootPostAuthor, postId: self.threadId)

                            //ContributedView(contributed: self.contributed)

                            Spacer()

                            // Redundant on iPad? The tags are in the thread list
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                LolView(lols: self.rootPostLols, expanded: true, postId: self.threadId)
                            }
                        }
                        .padding(.top, 10)
                        
                        // Full root post body and bubble
                        VStack {
                            if appSessionStore.blockedAuthors.contains(self.rootPostAuthor) {
                                HStack () {
                                    Text("[blocked]")
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                            } else {
                                HStack () {
                                    RichTextView(topBlocks: self.rootPostRichText).fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                            }
                            
                            // Tag and Reply
                            if appSessionStore.isSignedIn {
                                HStack {
                                    Text(self.rootPostDate)
                                        .font(.caption)
                                        .foregroundColor(Color("NoDataLabel"))
                                    Spacer()
                                    if self.threadId == 0 {
                                        TagPostView(postId: self.postId)
                                        Spacer().frame(width: 10)
                                        ComposePostView(postId: self.postId)
                                    } else {
                                        TagPostView(postId: self.threadId)
                                        Spacer().frame(width: 10)
                                        ComposePostView(postId: self.threadId)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.bottom, 10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(RoundedCornersView(color: Color("ChatBubblePrimary")))
                        .padding(.bottom, 10)
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: -5, trailing: 10))
                    .id(9999999999991)
                    .contextMenu {
                        PostContextView(showingWhosTaggingView: self.$showingWhosTaggingView, showingNewMessageView: self.$showingNewMessageView, messageRecipient: self.$messageRecipient, messageSubject: self.$messageSubject, messageBody: self.$messageBody, collapsed: self.$collapsePost, author: self.rootPostAuthor, postId: self.threadId, isRootPost: true, postBody: self.rootPostBody)
                    }
                    
                    // No replies yet
                    if postList.count < 1 {
                        Spacer()
                        HStack {
                            Text("No replies, be the first to post.")
                                .font(.body)
                                .bold()
                                .foregroundColor(Color("NoDataLabel"))
                        }
                        Spacer()
                    }
                    
                    // Replies
                    ForEach(postList, id: \.id) { post in
                        if post.id != post.threadId {
                            VStack {
                                HStack {
                                    
                                    // Reply preview
                                    if self.selectedPost != post.id {
                                        PostPreviewView(username: self.username, postId: post.id, postBody: post.body, replyLines: self.replyLines[post.id] == nil ? String(repeating: " ", count: 5) : self.replyLines[post.id]!, postCategory: post.category, postStrength: postStrength[post.id], postAuthor: post.author, postLols: post.lols, op: self.rootPostAuthor
                                        )
                                    }
                                    
                                    // Reply expanded
                                    if self.selectedPost == post.id {
                                        PostExpandedView(username: self.username, postId: post.id, postBody: post.body, replyLines: self.replyLines[post.id] == nil ? String(repeating: " ", count: 5) : self.replyLines[post.id]!, postCategory: post.category, postStrength: postStrength[post.id], postAuthor: post.author, postLols: post.lols, postRichText: self.selectedPostRichText, postDateTime: post.date, op: self.rootPostAuthor)
                                    }
                                    
                                }
                                .padding(.horizontal, 10)
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .contextMenu {
                                    PostContextView(showingWhosTaggingView: self.$showingWhosTaggingView, showingNewMessageView: self.$showingNewMessageView, messageRecipient: self.$messageRecipient, messageSubject: self.$messageSubject, messageBody: self.$messageBody, collapsed: self.$collapsePost, author: post.author, postId: post.id, postBody: post.body)
                                }
                                .onTapGesture(count: 1) {
                                    chatStore.activePostId = post.id
                                    self.chatStore.scrollTargetThread = post.id
                                    self.selectedPostRichText = RichTextBuilder.getRichText(postBody: post.body)
                                    if appSessionStore.disableAnimation {
                                        self.selectedPost = post.id
                                    } else {
                                        withAnimation {
                                            self.selectedPost = post.id
                                        }
                                    }
                                }
                                
                            }
                            .id(post.id)
                        }
                    }
                    
                    // Padding so we can see the bottom post (and scroll to bottom)
                    VStack {
                        Spacer().frame(width: UIScreen.main.bounds.width, height: 30)
                    }.id(9999999999993)
                    
                }
                .environmentObject(chatStore)
            } else {
                LazyVStack {
                    if self.postId > 0 || self.replyCount >= self.loadingLimit {
                        LoadingView(show: .constant(true), title: .constant(""))
                    } else {
                        Text(" ")
                    }
                }
            }
        }
        
        // Update view contents on iPad when thread selected
        .onReceive(chatStore.$activeThreadId) { _ in
            if UIDevice.current.userInterfaceIdiom == .pad {
                chatStore.scrollTargetThreadTop = 9999999999991
                self.selectedPost = 0
                getThreadData()
                self.postList = [ChatPosts]()
                self.postStrength = [Int: Double]()
                getPostList(parentId: self.threadId)
            }
        }
        
        // If refreshing thread after posting
        .onReceive(chatStore.$didGetThreadStart) { value in
            if value && self.chatStore.didSubmitPost && chatStore.activeThreadId == self.threadId {
                chatStore.didGetThreadStart = false
                self.selectedPost = 0
                self.isGettingThread = true
                /*
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15)) {
                    chatStore.didGetThreadFinish = true
                }
                */
            }
        }
        
        // When done refreshing (after posting or pull to refresh)
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
                getPostList(parentId: self.threadId)
                self.isGettingThread = false
                self.canRefresh = true
            }
        }
        
        // Disable while getting new data
        .disabled(self.isGettingThread || chatStore.gettingThread)
        
        // Fetch data and settings on load
        .onAppear(perform: {
            appSessionStore.currentViewName = "ThreadView"
            
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
                getUserData()
                getThreadData()
                getPostList(parentId: self.threadId)
                return
            }
            
            func getData() -> Void {
                print("getData begin")
                getUserData()
                getThreadData()
                if UIDevice.current.userInterfaceIdiom == .phone {
                    getPostList(parentId: self.threadId)
                }
                self.threadNavigationLocation = CGPoint(x: self.appSessionStore.threadNavigationLocationX, y: self.appSessionStore.threadNavigationLocationY)
                print("getData end")
            }
            
            if self.postId > 0 || self.replyCount >= self.loadingLimit {
                // Let the view load so we don't get stuck on the list screen
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
                    getData()
                }
            } else {
                // Load immediately
                getData()
            }
        })
        
        // Stop posting, refreshing or tagging
        .onDisappear {
            self.postList = [ChatPosts]()
            self.postStrength = [Int: Double]()
            self.chatStore.didSubmitPost = false
            self.chatStore.didGetThreadStart = false
            self.chatStore.didGetThreadFinish = false
            self.isGettingThread = false
            chatStore.showingTagNotice = false
        }
        
        // Loading and Alerts
        .overlay(LoadingView(show: self.$isGettingThread, title: .constant("")))
        .overlay(NoticeView(show: $chatStore.showingTagNotice, message: $chatStore.taggingNoticeText))
        .overlay(NoticeView(show: $chatStore.showingFavoriteNotice, message: .constant("Added User!")))
        
        // Thread Navigation
        .overlay(
            GeometryReader { geometry in
                VStack (alignment: .trailing) {
                    if !self.appSessionStore.threadNavigation || self.postCount < 2 {
                        EmptyView()
                    }
                    else if self.isGettingThread {
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            DisabledThreadNavigationView()
                                .position(threadNavigationLocation)
                                .gesture(threadNavigationDrag)
                        } else if UIDevice.current.userInterfaceIdiom == .pad {
                            DisabledThreadNavigationView()
                                .position(CGPoint(x: geometry.size.width - 80, y: geometry.size.height - 50))
                        }
                    } else {
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            ThreadNavigationView(nextAction: showNextReply, previousAction: showPreviousReply)
                            .position(threadNavigationLocation)
                            .gesture(threadNavigationDrag)
                        } else if UIDevice.current.userInterfaceIdiom == .pad {
                            ThreadNavigationView(nextAction: showNextReply, previousAction: showPreviousReply)
                            .position(CGPoint(x: geometry.size.width - 80, y: geometry.size.height - 50))
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        )

        // View settings
        .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle(UIDevice.current.userInterfaceIdiom == .pad ? "Chat" : "Thread", displayMode: .inline)
        
        // Who's Tagging & Compose Message
        .navigationBarItems(leading: Spacer().frame(width: 26, height: 16), trailing:
                HStack {
                    WhosTaggingView(showingWhosTaggingView: self.$showingWhosTaggingView)
                    NewMessageView(showingNewMessageSheet: self.$showingNewMessageView, messageId: Binding.constant(0), recipientName: self.$messageRecipient, subjectText: self.$messageSubject, bodyText: self.$messageBody)
                    
                }
        )
    }
}

struct ThreadDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ThreadDetailView(threadId: .constant(999999992), postId: .constant(0), replyCount: .constant(20), isSearchResult: .constant(false))
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
