//
//  macOSThreadViewOld.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct macOSThreadViewOld: View {
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
    
    @State private var showingTagSheet: Bool = false
    @State private var showingComposeSheet: Bool = false
    
    @State private var isThreadCollapsed: Bool = false
    @State private var showingCollapseAlert: Bool = false
    @State private var isThreadExpanded: Bool = false
    
    @State private var selectedPost = 0
    @State private var selectedPostRichText = [RichTextBlock]()
    
    @State private var selectedTag = 0
    
    @State private var showingNotice: Bool = false
    @State private var noticeMessage: String = ""
    
    private func getThreadData() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
                if let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first {
                    self.rootPostCategory = rootPost.category
                    self.rootPostAuthor = rootPost.author
                    self.rootPostBody = rootPost.body
                    self.rootPostDate = rootPost.date
                    self.rootPostLols = rootPost.lols
                }
                self.replyCount = thread.posts.count - 1
                self.recentPosts = thread.posts.filter({ return $0.parentId != 0 }).sorted(by: { $0.id > $1.id })
                
            }
        } else {
            let threads = chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
            
            if let thread = threads.filter({ return $0.threadId == self.threadId }).first {
                self.contributed = PostDecorator.checkParticipatedStatus(thread: thread, author: self.rootPostAuthor)
                if let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first {
                    self.rootPostCategory = rootPost.category
                    self.rootPostAuthor = rootPost.author
                    self.rootPostBody = rootPost.body
                    self.rootPostDate = rootPost.date
                    self.rootPostLols = rootPost.lols
                }
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
        ZStack {
            if !self.isThreadCollapsed {
                
                VStack (alignment: .leading) {
                    
                    ThreadCategoryColor[self.rootPostCategory].frame(height: 5)
                    
                    HStack {
                        AuthorNameView(name: self.rootPostAuthor, postId: self.threadId, bold: true)
                        
                        ContributedView(contributed: self.contributed)
                        
                        LolView(lols: self.rootPostLols, capsule: true, postId: self.threadId)

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
                        
                        if appSessionStore.isSignedIn {
                            Image(systemName: "tag")
                                .imageScale(.large)
                                .onTapGesture(count: 1) {
                                    self.showingTagSheet.toggle()
                                }
                        
                            Image(systemName: "arrowshape.turn.up.left")
                                .imageScale(.large)
                                .onTapGesture(count: 1) {
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    //.id(self.threadId)
                    
                    // Root post body
                    VStack (alignment: .leading) {
                        RichTextView(topBlocks: self.rootPostRichText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 20)
                    .onAppear() {
                        self.rootPostRichText = RichTextBuilder.getRichText(postBody: self.rootPostBody)
                    }
                    
                    // -----
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
                                                .foregroundColor(appSessionStore.username.lowercased() == post.author.lowercased() ? Color(NSColor.systemTeal) : Color.primary)
                                                .lineLimit(1)
                                            Spacer()
                                            AuthorNameView(name: post.author, postId: post.id)
                                            LolView(lols: post.lols, postId: post.id)
                                        }
                                        .padding(.top, 2)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                                
                                // Expand thread button
                                VStack (alignment: .center) {
                                    Button(action: {
                                        //withAnimation {
                                            self.isThreadExpanded = true
                                        //}
                                        if postList.count < 1 {
                                            getPostList(parentId: self.threadId)
                                        }
                                    }, label: {
                                        Image(systemName: "ellipsis")
                                            .imageScale(.large)
                                            .padding(.horizontal, 20)
                                            .padding(.bottom, 20)
                                            .contentShape(Rectangle())

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
                                //withAnimation {
                                    self.isThreadExpanded = false
                                //}
                            }, label: {
                                Image(systemName: "ellipsis")
                                    .imageScale(.large)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 20)
                                    .contentShape(Rectangle())
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
                                            macOSPostExpandedView(postId: .constant(post.id), postAuthor: .constant(post.author), replyLines: self.$replyLines[post.id], lols: .constant(post.lols), postText: self.$selectedPostRichText)
                                        }
                                        //.id(post.id)
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
                                        //.id(post.id)
                                        .contentShape(Rectangle())
                                        .onTapGesture(count: 1) {
                                            //withAnimation {
                                                selectedPost = post.id
                                            //}
                                        }
                                    }
                                    
                                }
                                //.id(post.id)
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
                
                // Contributed indicator bar
                if self.contributed {
                    HStack {
                        GeometryReader { categoryGeo in
                            Path { categoryPath in
                                categoryPath.move(to: CGPoint(x: 0, y: 0))
                                categoryPath.addLine(to: CGPoint(x: 0, y: categoryGeo.size.height - 10))
                                categoryPath.addLine(to: CGPoint(x: categoryGeo.size.width, y: categoryGeo.size.height - 10))
                                categoryPath.addLine(to: CGPoint(x: categoryGeo.size.width, y: 0))
                            }
                            .fill(Color(NSColor.systemTeal))
                        }
                        .frame(width: 3)
                        .offset(x: 8, y: 0)
                        Spacer()
                    }
                }
                
            } else {
                Spacer().frame(height: 8)
            }
            
            // Notices liked "Tagged!" etc...
            macOSNoticeView(show: self.$showingNotice, message: self.$noticeMessage)
        }
        
        // Collapse thread?
        .alert(isPresented: self.$showingCollapseAlert) {
            Alert(title: Text("Hide Thread?"), message: Text(""), primaryButton: .cancel(), secondaryButton: Alert.Button.default(Text("OK"), action: {
                self.isThreadCollapsed = true
                appSessionStore.collapsedThreads.append(self.threadId)
            }))
        }
        
        // Tags drop down
        .sheet(isPresented: $showingTagSheet) {
            VStack {
                Text("Tag This Post?")
                    .font(.title)
                    .bold()
                
                Text("If already tagged, the selected tag will be removed.")
                    .font(.subheadline)
                    .padding(.init(top: 10, leading: 60, bottom: 10, trailing: 60))
                
                Picker("Tag", selection: $selectedTag, content: {
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
                    Button("Cancel") {
                        self.showingTagSheet = false
                    }
                    
                    Button("OK") {
                        self.showingTagSheet = false
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .frame(width: 300, height: 200)
        }
        
    }
}

struct macOSThreadViewOld_Previews: PreviewProvider {
    static var previews: some View {
        macOSThreadViewOld(threadId: .constant(999999992))
            .previewLayout(.fixed(width: 640, height: 960))
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}