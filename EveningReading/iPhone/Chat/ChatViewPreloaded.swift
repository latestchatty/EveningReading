//
//  ChatViewPreloaded.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/31/21.
//

import SwiftUI

struct ChatViewPreloaded: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore

    @State private var isGettingChat: Bool = false
    
    @State private var username: String = ""

    @State private var rootPosts: [ChatPosts] = [ChatPosts]()
    @State private var rootPostsBody: [Int : String] = [:]
    @State private var rootPostsDate: [Int : Double] = [:]
    @State private var rootPostsReplyCount: [Int : Int] = [:]
    @State private var rootPostsContributed: [Int : Bool] = [:]
    
    private func filteredThreads() -> [ChatThread] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            return Array(chatData.threads)
        }
        let threads = chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        return Array(threads)
    }
    
    private func getRootPostData() {
        rootPosts.removeAll()
        rootPostsBody.removeAll()
        rootPostsDate.removeAll()
        rootPostsReplyCount.removeAll()
        rootPostsContributed.removeAll()
        
        let threads = chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        
        for thread in threads {
            if let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first {
                rootPosts.append(rootPost)
                rootPostsBody[rootPost.id] = rootPost.body.getPreview
                rootPostsDate[rootPost.id] = rootPost.date.getTimeRemaining()
                rootPostsReplyCount[rootPost.id] = thread.posts.count - 1
                rootPostsContributed[rootPost.id] = PostDecorator.checkParticipatedStatus(thread: thread, author: rootPost.author)
            }
        }
    }
    
    private func getUserData() {
        let user: String? = KeychainWrapper.standard.string(forKey: "Username")
        self.username = user?.lowercased() ?? ""
    }

    var body: some View {
        VStack {
            
            // Comment out to preview
            //GoToPostView(currentViewName: "ChatView")
            
            RefreshableScrollView(height: 70, refreshing: self.$chatStore.gettingChat, scrollTarget: self.$chatStore.scrollTargetChat, scrollTargetTop: self.$chatStore.scrollTargetChatTop) {
                
                // Scroll to top
                VStack {
                    Spacer().frame(maxWidth: .infinity).frame(height: 1)
                }.id(9999999999991)
                
                // All non-hidden threads
                ForEach(rootPosts, id: \.self) { post in
                    ThreadPreviewView(activeThreadId: .constant(0), rootPost: post, rootPostBodyPreview: rootPostsBody[post.id] ?? "", rootPostDate: rootPostsDate[post.id] ?? 0, replyCount: rootPostsReplyCount[post.id] ?? 0, contributed: rootPostsContributed[post.id] ?? false)
                        .padding(.bottom, -25)
                        .id(post.threadId)
                }
                
                // Scroll to bottom / padding
                VStack {
                    Spacer().frame(maxWidth: .infinity).frame(height: 30)
                }.id(9999999999993)
                
            }

        }
        
        // View settings
        .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Chat", displayMode: .inline)
        
        // New thread button
        .navigationBarItems(leading: Spacer().frame(width: 26, height: 16), trailing: ComposePostView(isRootPost: true))

        // If refreshing thread after posting
        .overlay(LoadingView(show: self.$isGettingChat, title: .constant("")))
                
        // Fetching chat data
        .onReceive(chatStore.$didGetChatStart) { value in
            if value && self.chatStore.didSubmitPost {
                chatStore.didGetChatStart = false
                self.isGettingChat = true
                self.chatStore.gettingChat = true
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15)) {
                    chatStore.didGetChatFinish = true
                }
            }
        }
        
        // Finished getting chat data
        .onReceive(chatStore.$didGetChatFinish) { value in
            self.isGettingChat = false
            getRootPostData()
        }
        
        // Disable while getting new data
        .disabled(chatStore.gettingChat)
        
        // Reset active thread on iPhone
        .onAppear() {
            appSessionStore.currentViewName = "ChatView"
            getUserData()
            if UIDevice.current.userInterfaceIdiom == .phone {
                chatStore.activeThreadId = 0
            }
        }
    }
}
