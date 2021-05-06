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
    @State private var rootPostDate: String = "2020-08-14T21:05:00Z"
    @State private var rootPostLols: [ChatLols] = [ChatLols]()
    @State private var contributed: Bool = false
    @State private var showThread: Bool = false
    
    @State private var postList = [ChatPosts]()
        
    private func getThreadData() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
                let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
                self.rootPostCategory = rootPost?.category ?? "ontopic"
                self.rootPostAuthor = rootPost?.author ?? ""
                self.rootPostBody = rootPost?.body.getPreview ?? ""
                self.rootPostDate = rootPost?.date ?? "2020-08-14T21:05:00Z"
                self.rootPostLols = rootPost?.lols ?? [ChatLols]()
                
                self.showThread = true
            } else {
                self.showThread = false
            }
        }
        if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
            let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
            self.rootPostCategory = rootPost?.category ?? "ontopic"
            self.rootPostAuthor = rootPost?.author ?? ""
            self.rootPostBody = rootPost?.body.getPreview ?? ""
            self.rootPostDate = rootPost?.date ?? "2020-08-14T21:05:00Z"
            self.rootPostLols = rootPost?.lols ?? [ChatLols]()
            
            self.showThread = true
        } else {
            self.showThread = false
        }
    }
    
    private func getPostList(parentId: Int) {
        if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
            let replies = thread.posts.filter({ return $0.parentId == parentId }).sorted(by: { $0.id < $1.id })
            
            for post in replies {
                postList.append(post)
                getPostList(parentId: post.id)
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
                            HStack () {
                                Text("\(self.rootPostBody)")
                                    .font(.body)
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                        }
                        .frame(maxWidth: .infinity)
                        .background(RoundedCornersView(color: Color("ChatBubblePrimary")))
                        .padding(.bottom, 10)
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
                    .id(9999999999991)
                    
                    // Replies
                    ForEach(postList, id: \.id) { post in
                        HStack {
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
                                //.fontWeight(recentPostOpacity[replyId] != nil ? PostWeight[recentPostOpacity[replyId]!] : .regular)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .font(.callout)
                                .foregroundColor(colorScheme == .dark ? Color(UIColor.white) : Color(UIColor.black))
                                //.opacity(recentPostOpacity[replyId] != nil ? recentPostOpacity[replyId]! : 0.75)
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
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity)
                        .id(post.id)
                    }
                }
                
            }
        }
        .onAppear(perform: {
            getThreadData()
            if UIDevice.current.userInterfaceIdiom == .phone {
                getPostList(parentId: self.threadId)
            }
        })
        .onReceive(self.chatStore.$activeThreadId) { _ in
            if UIDevice.current.userInterfaceIdiom == .pad {
                getThreadData()
                postList = [ChatPosts]()
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
        ThreadDetailView(threadId: .constant(9999999992))
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore())
            .environmentObject(ChatStore(service: ChatService()))
    }
}
