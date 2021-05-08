//
//  ThreadDetailView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct ThreadDetailView: View {
    @Environment(\.colorScheme) var colorScheme
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
    @State private var showThread: Bool = false
    
    @State private var postList = [ChatPosts]()
    @State private var postStrength = [Int: Double]()
    @State private var replyLines = [Int: String]()
    
    @State private var selectedPost = 0
    @State private var selectedPostRichText = [RichTextBlock]()
    
    private func getThreadData() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
                let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
                self.rootPostCategory = rootPost?.category ?? "ontopic"
                self.rootPostAuthor = rootPost?.author ?? ""
                self.rootPostBody = rootPost?.body ?? ""
                self.rootPostRichText = RichTextBuilder.getRichText(postBody: self.rootPostBody)
                self.rootPostDate = rootPost?.date ?? "2020-08-14T21:05:00Z"
                self.rootPostLols = rootPost?.lols ?? [ChatLols]()
                self.showThread = true
            } else {
                self.showThread = false
            }
        } else {
            if let thread = chatStore.threads.filter({ return $0.threadId == self.threadId }).first {
                let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
                self.rootPostCategory = rootPost?.category ?? "ontopic"
                self.rootPostAuthor = rootPost?.author ?? ""
                self.rootPostBody = rootPost?.body ?? ""
                self.rootPostRichText = RichTextBuilder.getRichText(postBody: self.rootPostBody)
                self.rootPostDate = rootPost?.date ?? "2020-08-14T21:05:00Z"
                self.rootPostLols = rootPost?.lols ?? [ChatLols]()
                self.showThread = true
            } else {
                self.showThread = false
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
        VStack {
            if self.showThread {
                
                RefreshableScrollView(height: 70, refreshing: self.$chatStore.loadingThread, scrollTarget: self.$chatStore.scrollTargetThread, scrollTargetTop: self.$chatStore.scrollTargetThreadTop) {
                        
                    // Root Post
                    VStack {
                        HStack (alignment: .center) {
                            AuthorNameView(name: self.rootPostAuthor, postId: self.threadId)

                            ContributedView(contributed: self.contributed)

                            Spacer()

                            if UIDevice.current.userInterfaceIdiom == .phone {
                                LolView(lols: self.rootPostLols, expanded: true)
                            }
                        }
                        .padding(.top, 10)
                        
                        VStack {
                            // Full root post body
                            HStack () {
                                RichTextView(topBlocks: self.rootPostRichText).fixedSize(horizontal: false, vertical: true)
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            /*
                            HStack () {
                                Text("\(self.rootPostBody)")
                                    .font(.body)
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            */
                            
                            // Tag and reply
                            if appSessionStore.isSignedIn {
                                HStack {
                                    Spacer()
                                    TagPostView()
                                    Spacer().frame(width: 10)
                                    ComposePostView()
                                }
                                .padding(.horizontal, 10)
                                .padding(.bottom, 10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(RoundedCornersView(color: Color("ChatBubblePrimary")))
                        .padding(.bottom, 10)
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
                    .id(9999999999991)
                    
                    // Replies
                    ForEach(postList, id: \.id) { post in
                        VStack {
                            HStack {
                                
                                // Reply preview
                                if self.selectedPost != post.id {
                                    // Reply lines
                                    Text(self.replyLines[post.id] == nil ? String(repeating: " ", count: 5) : self.replyLines[post.id]!)
                                        .lineLimit(1)
                                        .fixedSize()
                                        .font(.custom("replylines", size: 25, relativeTo: .callout))
                                        .foregroundColor(Color("replyLines"))

                                    // Rarely a post category on a reply
                                    if post.category == "nws" {
                                        Text("nws")
                                            .bold()
                                            .lineLimit(1)
                                            .font(.footnote)
                                            .foregroundColor(Color(UIColor.systemRed))
                                    } else if post.category == "stupid" {
                                        Text("stupid")
                                            .bold()
                                            .lineLimit(1)
                                            .font(.footnote)
                                            .foregroundColor(Color(UIColor.systemGreen))
                                    } else if post.category == "informative" {
                                        Text("inf")
                                            .bold()
                                            .lineLimit(1)
                                            .font(.footnote)
                                            .foregroundColor(Color(UIColor.systemBlue))
                                    }
                                    
                                    // Post preview
                                    Text(post.body.getPreview)
                                        .fontWeight(postStrength[post.id] != nil ? PostWeight[postStrength[post.id]!] : .regular)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .font(.callout)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.white) : Color(UIColor.black))
                                        .opacity(postStrength[post.id] != nil ? postStrength[post.id]! : 0.75)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    // Maybe show post author
                                    if self.appSessionStore.displayPostAuthor {
                                        AuthorNameView(name: post.author, postId: post.id)
                                    }
                                    
                                    // Lols
                                    HStack {
                                        LolView(lols: post.lols)
                                    }
                                }
                                
                                // Reply expanded
                                if self.selectedPost == post.id {
                                    VStack {
                                        HStack {
                                            // Reply lines
                                            Text(self.replyLines[post.id] == nil ? String(repeating: " ", count: 5) : self.replyLines[post.id]!)
                                                .lineLimit(1)
                                                .fixedSize()
                                                .font(.custom("replylines", size: 25, relativeTo: .callout))
                                                .foregroundColor(Color("replyLines"))
                                            
                                            AuthorNameView(name: post.author, postId: post.id)
                                            
                                            Spacer()
                                            
                                            // Lols
                                            HStack {
                                                LolView(lols: post.lols, expanded: true)
                                            }
                                        }
                                        // Expanded reply rich text and bubble
                                        VStack {
                                            HStack {
                                                RichTextView(topBlocks: self.selectedPostRichText).fixedSize(horizontal: false, vertical: true)
                                                Spacer()
                                            }
                                            .padding(10)
                                            .frame(maxWidth: .infinity)
                                            
                                            // Tag and reply
                                            if appSessionStore.isSignedIn {
                                                HStack {
                                                    Spacer()
                                                    TagPostView()
                                                    Spacer().frame(width: 10)
                                                    ComposePostView()
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
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity)
                            .onTapGesture(count: 1) {
                                withAnimation {
                                    self.selectedPostRichText = RichTextBuilder.getRichText(postBody: post.body)
                                    self.selectedPost = post.id
                                }
                            }
                            
                        }
                        .id(post.id)
                    }
                    
                    // Padding so we can see the bottom post
                    VStack {
                        Spacer().frame(width: UIScreen.main.bounds.width, height: 30)
                    }.id(9999999999993)
                    
                }
                .environmentObject(chatStore)
                
            }
        }
        .onAppear(perform: {
            getThreadData()
            if UIDevice.current.userInterfaceIdiom == .phone {
                getPostList(parentId: self.threadId)
            }
        })
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
        .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle(UIDevice.current.userInterfaceIdiom == .pad ? "Chat" : "Thread", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 26, height: 16))
    }
}

struct ThreadDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ThreadDetailView(threadId: .constant(999999992))
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
