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
    @State private var rootPostDate: String = "2020-08-14T21:05:00Z"
    @State private var contributed: Bool = false
    @State private var replyCount: Int = 0
    @State private var recentPosts: [ChatPosts] = [ChatPosts]()
    @State private var hasLols: Bool = false
    @State private var lols = [String: Int]()
    @State private var lolTypeCount: Int = 0
    
    @State private var isThreadCollapsed: Bool = false
    @State private var showingCollapseAlert: Bool = false
    
    @State private var replyPreviewColumns: [GridItem] = [
        GridItem(.flexible(maximum: 120)),
        GridItem(.flexible())
    ]
    
    private func getThreadData() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
                let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
                self.rootPostCategory = rootPost?.category ?? "ontopic"
                self.rootPostAuthor = rootPost?.author ?? ""
                self.rootPostBody = rootPost?.body.getPreview ?? ""
                self.replyCount = thread.posts.count - 1
                
                self.recentPosts = thread.posts.filter({ return $0.parentId != 0 }).sorted(by: { $0.id > $1.id })
                
                for lol in rootPost?.lols ?? [ChatLols]() {
                    if lol.count > 0 {
                        self.hasLols = true
                    }
                    lols[String("\(lol.tag)")] = lol.count
                    if lol.count > 0 {
                        lolTypeCount += 1
                    }
                }
            }
        }
        if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
            let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
            self.rootPostCategory = rootPost?.category ?? "ontopic"
            self.rootPostAuthor = rootPost?.author ?? ""
            self.rootPostBody = rootPost?.body.getPreview ?? ""
            self.replyCount = thread.posts.count - 1
            
            self.recentPosts = thread.posts.filter({ return $0.parentId != 0 }).sorted(by: { $0.id > $1.id })
            
            for lol in rootPost?.lols ?? [ChatLols]() {
                if lol.count > 0 {
                    self.hasLols = true
                }
                lols[String("\(lol.tag)")] = lol.count
                if lol.count > 0 {
                    lolTypeCount += 1
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
                        AuthorNameView(name: self.$rootPostAuthor, postId: self.$threadId)
                        
                        ContributedView(contributed: self.$contributed)
                        
                        if self.hasLols {
                            LolView(lols: self.$lols)
                        }
                        Spacer()

                        ReplyCountView(replyCount: self.$replyCount)
                        
                        TimeRemainingIndicator(percent: .constant(self.rootPostDate.getTimeRemaining()))
                            .frame(width: 10, height: 10)
                        
                        Text(self.rootPostDate.getTimeAgo())
                            .font(.body)
                        
                        Image(systemName: "eye.slash")
                            .imageScale(.large)
                            .onTapGesture(count: 1) {
                                self.showingCollapseAlert.toggle()
                            }
                        
                        Image(systemName: "tag")
                            .imageScale(.large)
                            .onTapGesture(count: 1) {
                            }
                        
                        Image(systemName: "arrowshape.turn.up.left")
                            .imageScale(.large)
                            .onTapGesture(count: 1) {
                            }
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    
                    HStack {
                        Text("\(self.rootPostBody)")
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.bottom, 10)
                    }

                    Divider()
                    .padding(.init(top: 0, leading: 20, bottom: 10, trailing: 20))
                    
                    if self.replyCount > 0 {
                        VStack (alignment: .leading) {
                            
                            LazyVGrid(columns: self.replyPreviewColumns, alignment: .leading, spacing: 16) {
                                
                                ForEach(recentPosts.prefix(5), id: \.id) { post in
                                    //HStack {
                                        Text("\(post.author)")
                                            .font(.subheadline)
                                            .lineLimit(1)
                                            .foregroundColor(Color(NSColor.systemOrange))
                                        Text("\(post.body.getPreview)")
                                            .font(.subheadline)
                                            .lineLimit(1)
                                        //Spacer()
                                    //}
                                }
                            }
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.bottom, 5)
                            
                            VStack (alignment: .center) {
                                Image(systemName: "ellipsis")
                                    .imageScale(.large)
                                    .onTapGesture(count: 1) {
                                    }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    } else {
                        VStack (alignment: .center) {
                            Text("No replies, be the first to post.")
                                .bold()
                                .foregroundColor(Color("NoData"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.init(top: 0, leading: 20, bottom: 20, trailing: 20))
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
        .alert(isPresented: self.$showingCollapseAlert) {
            Alert(title: Text("Hide Thread?"), message: Text(""), primaryButton: .cancel(), secondaryButton: Alert.Button.default(Text("OK"), action: {
                self.isThreadCollapsed = true
            }))
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
