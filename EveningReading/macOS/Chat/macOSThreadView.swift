//
//  macOSThreadView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/11/21.
//

import SwiftUI

struct macOSThreadView: View {
    @EnvironmentObject var appSession: AppSession
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
    
    @State private var showingHideAlert = false
    @State private var hideThread = false
    
    private func getThreadData() {
        let threads = chatStore.threads.filter({ return self.appSession.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !appSession.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        
        if let thread = threads.filter({ return $0.threadId == self.threadId }).first {
            self.contributed = PostDecorator.checkParticipatedStatus(thread: thread, author: self.rootPostAuthor)
            if let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first {
                self.rootPostCategory = rootPost.category
                self.rootPostAuthor = rootPost.author
                self.rootPostBody = rootPost.body
                self.rootPostRichText = RichTextBuilder.getRichText(postBody: rootPost.body.replaceGTRT)
                self.rootPostDate = rootPost.date
                self.rootPostLols = rootPost.lols
            }
            self.replyCount = thread.posts.count - 1
        }
    }
    
    private func getPostList(parentId: Int) {
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
    
    private func setSelectedPost(_ postIndex: Int) {
        chatStore.activeParentId = postList[postIndex].id
        selectedPost = postList[postIndex].id
        chatStore.scrollTargetChat = postList[postIndex].id
    }
    
    private func showNextReply() {
        if postList.count > 0 {
            if self.selectedPost == 0 {
                setSelectedPost(0)
            } else {
                for i in 0..<self.postList.count {
                    if self.selectedPost == self.postList[i].id {
                        if i + 1 < self.postList.count {
                            setSelectedPost(i + 1)
                        } else {
                            setSelectedPost(0)
                        }
                        break
                    }
                }
            }
        }
    }
    
    private func showPreviousReply() {
        if postList.count > 0 {
            if self.selectedPost == 0 {
                setSelectedPost(postList.count - 1)
            } else {
                for i in 0..<self.postList.count {
                    if self.selectedPost == self.postList[i].id {
                        if i - 1 > -1 {
                            setSelectedPost(i - 1)
                        } else {
                            setSelectedPost(postList.count - 1)
                        }
                        break
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            
            if hideThread || appSession.collapsedThreads.contains(self.threadId) {
                
                Text("No thread selected.")
                    .font(.body)
                    .bold()
                    .foregroundColor(Color("NoDataLabel"))
                    .padding(.top, 10)
                
            } else {
            
                // Root post
                VStack (alignment: .leading) {
                    HStack {
                        AuthorNameView(name: self.rootPostAuthor, postId: self.threadId)
                        
                        ContributedView(contributed: self.contributed)

                        HStack {
                            Button(action: {
                                // previous
                                showPreviousReply()
                            }, label: {
                                EmptyView()
                            })
                            .buttonStyle(.plain)
                            .keyboardShortcut("a", modifiers: [])

                            Button(action: {
                                // next
                                showNextReply()
                            }, label: {
                                EmptyView()
                            })
                            .buttonStyle(.plain)
                            .keyboardShortcut("z", modifiers: [])
                        }
                        
                        Button(action: {
                            // refresh
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                                chatStore.showingRefreshThreadSpinner = true
                                chatStore.getThread()
                            }
                        }, label: {
                            Spacer().frame(width: 0)
                        })
                        .buttonStyle(.plain)
                        .keyboardShortcut("t", modifiers: [.command])
                        
                        Spacer()

                        Text("\(rootPostDate.getTimeRemaining()) left")
                            .foregroundColor(Color("NoDataLabel"))
                            .font(.body)
                            .help(rootPostDate.postTimestamp())
                        
                        Text("-")
                            .foregroundColor(Color("NoDataLabel"))
                        
                        ReplyCountView(replyCount: self.replyCount)
                            .padding(.trailing, 5)
                        
                        /*
                        Text(self.rootPostDate.getTimeAgo())
                            .foregroundColor(Color.gray)
                            .font(.body)
                        */

                        Image(systemName: "arrow.counterclockwise")
                            .imageScale(.large)
                            .onTapGesture(count: 1) {
                                chatStore.showingRefreshThreadSpinner = true
                                chatStore.getThread()
                            }
                        
                        macOSPostActionsView(name: self.rootPostAuthor, postId: self.threadId, showingHideThread: true)
                        
                        /*
                        Image(systemName: "eye.slash")
                            .imageScale(.large)
                            .onTapGesture(count: 1) {
                                self.showingHideAlert = true
                            }
                        .alert(isPresented: self.$showingHideAlert) {
                            Alert(title: Text("Hide thread?"), message: Text(""), primaryButton: .default(Text("Yes")) {
                                // collapse thread
                                self.appSession.collapsedThreads.append(self.threadId)
                                chatStore.activeThreadId = 0
                                self.hideThread = true
                            }, secondaryButton: .cancel() {
                                
                            })
                        }
                        */
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                    
                    // Root post body
                    VStack (alignment: .leading) {
                        RichTextView(topBlocks: appSession.blockedAuthors.contains(self.rootPostAuthor) ? RichTextBuilder.getRichText(postBody: "[blocked]") : self.rootPostRichText)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                    
                    if !appSession.blockedAuthors.contains(self.rootPostAuthor) {
                        HStack {
                            LolView(lols: self.rootPostLols, expanded: true, postId: self.threadId)
                                .padding(.trailing, 1)

                            Spacer()
                            
                            if appSession.isSignedIn {
                                macOSTagPostButton(postId: self.threadId)
                                Image(systemName: "link")
                                    .imageScale(.large)
                                    .onTapGesture(count: 1) {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString("https://www.shacknews.com/chatty?id=\(self.threadId)#item_\(self.threadId)", forType: .URL)
                                        chatStore.didCopyLink = true
                                    }
                                Image(systemName: "arrowshape.turn.up.left")
                                    .imageScale(.large)
                                    .onTapGesture(count: 1) {
                                        chatStore.newPostParentId = self.threadId
                                        chatStore.newReplyAuthorName = self.rootPostAuthor
                                        chatStore.showingNewPostSheet = true
                                    }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .background(Color("ThreadBubblePrimary"))
                .cornerRadius(10)
                .padding(.horizontal, 10)
                .padding(.top, 10)
            
                // Replies
                VStack(spacing: 0) {
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
                    if chatStore.hideReplies {
                        
                    } else {
                        ForEach(postList, id: \.id) { post in
                            HStack {
                                
                                // Reply expaned row
                                if chatStore.activeParentId == post.id {
                                    VStack {
                                        macOSPostExpandedView(postId: .constant(post.id), postAuthor: .constant(post.author), replyLines: self.$replyLines[post.id], lols: .constant(post.lols), postText: self.$selectedPostRichText, postDateTime: .constant(post.date),
                                            op: .constant(self.rootPostAuthor))
                                    }
                                    .onAppear() {
                                        // Load Rich Text
                                        self.selectedPostRichText = RichTextBuilder.getRichText(postBody: post.body)
                                    }
                                }
                                
                                // Reply preview row
                                if chatStore.activeParentId != post.id {
                                    HStack {
                                        macOSPostPreviewView(postId: .constant(post.id), postAuthor: .constant(post.author), replyLines: self.$replyLines[post.id], lols: .constant(post.lols), postText: .constant(post.body), postCategory: .constant(post.category), postStrength: .constant(postStrength[post.id]),
                                            op: .constant(self.rootPostAuthor)
                                        )}
                                    .contentShape(Rectangle())
                                    .onTapGesture(count: 1) {
                                        //withAnimation {
                                            chatStore.activeParentId = post.id
                                            selectedPost = post.id
                                        //}
                                    }
                                }
                                
                            }
                            .id(post.id)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
        }
        .onReceive(chatStore.$activeThreadId) { value in
            self.hideThread = false
            getThreadData()
            postList = [ChatPosts]()
            postStrength = [Int: Double]()
            replyLines = [Int: String]()
            getPostList(parentId: self.threadId)
            selectedPost = 0
            chatStore.scrollTargetChat = 0
        }
        .onReceive(chatStore.$didGetThreadFinish) { value in
            if value {
                getThreadData()
                postList = [ChatPosts]()
                postStrength = [Int: Double]()
                replyLines = [Int: String]()
                getPostList(parentId: self.threadId)
                chatStore.showingRefreshThreadSpinner = false
                chatStore.scrollTargetChat = 0
            }
        }
    }
}
