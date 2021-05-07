//
//  FullThreadView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct FullThreadView: View {
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
    @State private var recentPosts: [ChatPosts] = [ChatPosts]()
    
    @State private var postList = [ChatPosts]()
    @State private var postStrength = [Int: Double]()
    @State private var replyLines = [Int: String]()
    
    @State private var showingLolSheet: Bool = false
    @State private var showingComposeSheet: Bool = false
    
    @State private var isThreadCollapsed: Bool = false
    @State private var showingCollapseAlert: Bool = false
    @State private var isThreadExpanded: Bool = false
    
    @State private var selectedPost = 0
    @State private var selectedPostRichText = [RichTextBlock]()
    
    @State private var selectedLol = 0
    
    private func getThreadData() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
                let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
                self.rootPostCategory = rootPost?.category ?? "ontopic"
                self.rootPostAuthor = rootPost?.author ?? ""
                self.rootPostBody = rootPost?.body ?? ""
                self.rootPostDate = rootPost?.date ?? "2020-08-14T21:05:00Z"
                self.rootPostLols = rootPost?.lols ?? [ChatLols]()
                self.replyCount = thread.posts.count - 1
                self.recentPosts = thread.posts.filter({ return $0.parentId != 0 }).sorted(by: { $0.id > $1.id })
                
            }
        } else {
            let threads = chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
            
            if let thread = threads.filter({ return $0.threadId == self.threadId }).first {
                let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
                self.rootPostCategory = rootPost?.category ?? "ontopic"
                self.rootPostAuthor = rootPost?.author ?? ""
                self.rootPostBody = rootPost?.body ?? ""
                self.rootPostDate = rootPost?.date ?? "2020-08-14T21:05:00Z"
                self.rootPostLols = rootPost?.lols ?? [ChatLols]()
                self.replyCount = thread.posts.count - 1
                self.recentPosts = thread.posts.filter({ return $0.parentId != 0 }).sorted(by: { $0.id > $1.id })
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
            if !self.isThreadCollapsed {
                VStack (alignment: .leading) {
                    
                    ThreadCategoryColor[self.rootPostCategory].frame(height: 5)
                    
                    HStack {
                        AuthorNameView(name: self.rootPostAuthor, postId: self.threadId, bold: true)
                        
                        ContributedView(contributed: self.contributed)
                        
                        LolView(lols: self.rootPostLols, capsule: true)

                        Spacer()

                        ReplyCountView(replyCount: self.replyCount)
                        
                        TimeRemainingIndicator(percent: .constant(self.rootPostDate.getTimeRemaining()))
                            .frame(width: 12, height: 12)
                            .padding(.horizontal, 2)
                        
                        //Text(self.rootPostDate.getTimeAgo())
                        //    .font(.body)
                        
                        Image(systemName: "eye.slash")
                            .imageScale(.large)
                            .onTapGesture(count: 1) {
                                self.showingCollapseAlert.toggle()
                            }
                        
                        Image(systemName: "tag")
                            .imageScale(.large)
                            .onTapGesture(count: 1) {
                                self.showingLolSheet.toggle()
                            }
                        
                        Image(systemName: "arrowshape.turn.up.left")
                            .imageScale(.large)
                            .onTapGesture(count: 1) {
                            }
                    }
                    .padding(.horizontal, 20)
                    .id(self.threadId)
                    
                    VStack (alignment: .leading) {
                        RichTextView(topBlocks: self.rootPostRichText)
                            .fixedSize(horizontal: false, vertical: true)
                        /*
                        Text("\(self.rootPostBody)")
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                        
                        */
                    }
                    .padding(.horizontal, 20)
                    .onAppear() {
                        self.rootPostRichText = RichTextBuilder.getRichText(postBody: self.rootPostBody)
                    }
                    
                    Divider()
                    .padding(.init(top: 0, leading: 20, bottom: 10, trailing: 20))

                    if !self.isThreadExpanded {
                        
                        // Collapsed thread view
                        if self.replyCount > 0 {
                            VStack (alignment: .leading) {
                                
                                // Most recent posts
                                VStack {
                                    ForEach(recentPosts.prefix(5), id: \.id) { post in
                                        HStack {
                                            Text("\(post.body.getPreview)")
                                                .font(.body)
                                                .lineLimit(1)
                                            Spacer()
                                            AuthorNameView(name: post.author, postId: post.id)
                                            LolView(lols: post.lols)
                                        }
                                        .padding(.top, 2)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                                
                                // Expand thread button
                                VStack (alignment: .center) {
                                    Button(action: {
                                        withAnimation {
                                            self.isThreadExpanded = true
                                        }
                                        if postList.count < 1 {
                                            getPostList(parentId: self.threadId)
                                        }
                                    }, label: {
                                        Image(systemName: "ellipsis")
                                            .imageScale(.large)
                                            .padding(.horizontal, 20)
                                            .padding(.bottom, 20)

                                    })
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .frame(maxWidth: .infinity)
                                
                            }
                        } else {
                            
                            // No replies
                            VStack (alignment: .center) {
                                Text("No replies, be the first to post.")
                                    .bold()
                                    .foregroundColor(Color("NoData"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            
                        }
                        
                    } else {
                        
                        // Collapse thread button
                        VStack (alignment: .center) {
                            Button(action: {
                                withAnimation {
                                    self.isThreadExpanded = false
                                }
                            }, label: {
                                Image(systemName: "ellipsis")
                                    .imageScale(.large)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 20)

                            })
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .frame(maxWidth: .infinity)
                        
                    }
                    
                    if self.isThreadExpanded {
                        
                        // Expanded thread view
                        VStack {
                            ForEach(postList, id: \.id) { post in
                                HStack {
                                    // Reply expaned row
                                    if self.selectedPost == post.id {
                                        VStack {
                                            HStack {
                                                // Reply lines
                                                Text(self.replyLines[post.id] == nil ? String(repeating: " ", count: 5) : self.replyLines[post.id]!)
                                                    .lineLimit(1)
                                                    .fixedSize()
                                                    .font(.custom("replylines", size: 25, relativeTo: .callout))
                                                    .foregroundColor(Color("replyLines"))
                                                
                                                // Author
                                                AuthorNameView(name: post.author, postId: post.id)
                                                
                                                Spacer()
                                                
                                                // Lols
                                                LolView(lols: post.lols, expanded: true)
                                                    .padding(.top, 5)
                                            }
                                            HStack {
                                                VStack {
                                                    // Full post
                                                    RichTextView(topBlocks: self.selectedPostRichText)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                                .padding(8)
                                                Spacer()
                                                /*
                                                Text("\(post.body.getPreview)")
                                                    .font(.body)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .padding(8)
                                                Spacer()
                                                */
                                            }
                                            .frame(maxWidth: .infinity)
                                            .background(Color("ThreadBubbleSecondary"))
                                            .cornerRadius(5)
                                        }
                                        .onAppear() {
                                            // Load Rich Text
                                            self.selectedPostRichText = RichTextBuilder.getRichText(postBody: post.body)
                                        }
                                    }
                                    
                                    // Reply preview row
                                    if self.selectedPost != post.id {
                                        HStack {
                                            // Reply lines
                                            Text(self.replyLines[post.id] == nil ? String(repeating: " ", count: 5) : self.replyLines[post.id]!)
                                                .lineLimit(1)
                                                .fixedSize()
                                                .font(.custom("replylines", size: 25, relativeTo: .callout))
                                                .foregroundColor(Color("replyLines"))
                                            
                                            // Category (rarely)
                                            if post.category == "nws" {
                                                Text("nws")
                                                    .bold()
                                                    .lineLimit(1)
                                                    .font(.footnote)
                                                    .foregroundColor(Color(NSColor.systemRed))
                                            } else if post.category == "stupid" {
                                                Text("stupid")
                                                    .bold()
                                                    .lineLimit(1)
                                                    .font(.footnote)
                                                    .foregroundColor(Color(NSColor.systemGreen))
                                            } else if post.category == "informative" {
                                                Text("inf")
                                                    .bold()
                                                    .lineLimit(1)
                                                    .font(.footnote)
                                                    .foregroundColor(Color(NSColor.systemBlue))
                                            }
                                            
                                            // Post preview line
                                            Text("\(post.body.getPreview)")
                                                .font(.body)
                                                .fontWeight(postStrength[post.id] != nil ? PostWeight[postStrength[post.id]!] : .regular)
                                                .opacity(postStrength[post.id] != nil ? postStrength[post.id]! : 0.75)
                                                .lineLimit(1)
                                            Spacer()
                                            
                                            // Author
                                            AuthorNameView(name: post.author, postId: post.id)
                                            
                                            // Lols
                                            LolView(lols: post.lols)
                                        }
                                        .onTapGesture(count: 1) {
                                            withAnimation {
                                                selectedPost = post.id
                                            }
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
                .onAppear(perform: getThreadData)
                .frame(maxWidth: .infinity)
                .background(Color("ThreadBubblePrimary"))
                .cornerRadius(10)
                .padding(.init(top: 0, leading: 20, bottom: 10, trailing: 20))
            } else {
                Spacer().frame(height: 8)
            }
        }
        // Collapse thread?
        .alert(isPresented: self.$showingCollapseAlert) {
            Alert(title: Text("Hide Thread?"), message: Text(""), primaryButton: .cancel(), secondaryButton: Alert.Button.default(Text("OK"), action: {
                self.isThreadCollapsed = true
            }))
        }
        // Lol drop down
        .sheet(isPresented: $showingLolSheet) {
            VStack {
                Text("Tag This Post?")
                    .font(.body)
                    .bold()
                
                Text("If already tagged, you will untag any previous tags of the same type.")
                    .font(.subheadline)
                    .padding(.init(top: 10, leading: 60, bottom: 10, trailing: 60))
                
                Picker("Tag", selection: $selectedLol, content: {
                    Text("lol").tag(0)
                    Text("inf").tag(1)
                    Text("unf").tag(2)
                    Text("tag").tag(3)
                    Text("wtf").tag(4)
                    Text("wow").tag(5)
                    Text("aww").tag(6)
                })
                .padding(.horizontal, 60)
                
                HStack {
                    Button("OK") {
                        self.showingLolSheet = false
                    }
                    
                    Button("Cancel") {
                        self.showingLolSheet = false
                    }
                }
            }
            .frame(width: 300, height: 200)
        }
    }
}

struct FullThreadView_Previews: PreviewProvider {
    static var previews: some View {
        FullThreadView(threadId: .constant(9999999992))
            .previewLayout(.fixed(width: 640, height: 960))
            .environmentObject(AppSessionStore())
            .environmentObject(ChatStore(service: ChatService()))
    }
}
