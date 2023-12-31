//
//  watchOSThreadRow.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct watchOSThreadRow: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService
    
    @Binding var threadId: Int
    
    @State private var categoryWidth: CGFloat = 3
    @State private var rootPostCategory: String = "ontopic"
    @State private var rootPostAuthor: String = ""
    @State private var rootPostBodyPreview: String = ""
    @State private var rootPostDate: String = "2020-08-14T21:05:00Z"
    @State private var rootPostLols: [ChatLols] = [ChatLols]()
    @State private var contributed: Bool = false
    @State private var replyCount: Int = 0
    
    @State private var isThreadCollapsed: Bool = false
    @State private var showingCollapseAlert: Bool = false
    @State private var showingPost: Bool = false
    
    @State private var allAuthors: [String] = [""]
    
    @ObservedObject private var watchService = WatchService.shared
    
    private func getThreadData() {
        if let thread = chatService.threads.filter({ return $0.threadId == self.threadId }).first {
            setThreadData(thread)
        }
    }
    
    private func setThreadData(_ thread: ChatThread) {
        let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
        self.rootPostCategory = rootPost?.category ?? "ontopic"
        self.rootPostAuthor = rootPost?.author ?? ""
        self.rootPostBodyPreview = rootPost?.body.getPreview ?? ""
        self.rootPostDate = rootPost?.date ?? "2020-08-14T21:05:00Z"
        self.replyCount = thread.posts.count - 1
        self.rootPostLols = rootPost?.lols ?? [ChatLols]()
        allAuthors.removeAll()
        for post in thread.posts {
            allAuthors.append(post.author.lowercased())
        }
    }
    
    var body: some View {
        VStack {
            
            // Fixes navigation bug
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.frame(width: 0, height: 0)
            
            if !self.isThreadCollapsed {
                VStack (alignment: .leading) {
                    // Thread details
                    HStack {
                        AuthorNameView(name: self.rootPostAuthor, postId: self.threadId, navLink: true)
                        ContributedView(contributed: self.contributed)
                        Spacer()
                        LolView(lols: self.rootPostLols, postId: self.threadId)
                        ReplyCountView(replyCount: self.replyCount)
                    }
                    // Thread body preview
                    HStack {
                        Text(appService.getPostBodyFor(name: self.rootPostAuthor, body: self.rootPostBodyPreview))
                            .font(.footnote)
                            .lineLimit(3)
                            .onTapGesture(count: 1) {
                                self.showingPost.toggle()
                            }
                            .onLongPressGesture {
                                self.showingCollapseAlert.toggle()
                            }
                        NavigationLink(destination: watchOSPostDetail(postId: .constant(self.threadId)).environmentObject(appService).environmentObject(chatService), isActive: self.$showingPost) {
                            EmptyView()
                        }.frame(width: 0, height: 0)
                        Spacer()
                    }
                }
                .padding()
                .background(
                    allAuthors.contains(watchService.plainTextUsername) ? Color("ThreadBubbleContributed") : Color("ThreadBubblePrimary")
                )
                .cornerRadius(5)
                .onAppear(perform: getThreadData)
            } else {
                Spacer()
            }
            
        }
        // Show when collapsing a thread
        .alert(isPresented: self.$showingCollapseAlert) {
            Alert(title: Text("Hide Thread?"), message: Text(""), primaryButton: .cancel(), secondaryButton: Alert.Button.default(Text("OK"), action: {
                self.isThreadCollapsed = true
                appService.collapsedThreads.append(threadId)
            }))
        }
        
    }
}
