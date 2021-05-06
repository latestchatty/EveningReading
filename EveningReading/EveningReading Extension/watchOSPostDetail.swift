//
//  watchOsPostDetail.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct watchOsPostDetail: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    @Binding var postId: Int
    
    @State private var postCategory: String = "ontopic"
    @State private var postAuthor: String = ""
    @State private var contributed: Bool = false
    @State private var postBody: String = ""
    @State private var postDate: String = "2020-08-14T21:05:00Z"
    @State private var hasLols: Bool = false
    @State private var lols = [String: Int]()
    @State private var lolTypeCount: Int = 0
    @State private var replies: [ChatPosts] = [ChatPosts]()
    
    @State private var isRootPost: Bool = false
    
    private func getThreadData() {
        //if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        //{
            let thread = chatData.threads.filter { !$0.posts.isEmpty && $0.posts.contains(where: { post in post.id == self.postId }) }.first
            
            if let childPost = thread?.posts.filter({ return $0.id == self.postId }).first {
                
                self.postCategory = childPost.category
                self.postAuthor = childPost.author
                self.postBody = childPost.body.getPreview
                
                for lol in childPost.lols {
                    if lol.count > 0 {
                        self.hasLols = true
                    }
                    lols[String("\(lol.tag)")] = lol.count
                    if lol.count > 0 {
                        lolTypeCount += 1
                    }
                }
                
                self.replies = thread?.posts.filter({ return $0.parentId == self.postId }) ?? [ChatPosts]()
            } else {
                self.postAuthor = "none"
            }
        //}
    }
    
    var body: some View {
        ScrollView {
            
            // Fixes SwiftUI/watchOS/simulator navigation bug?
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.frame(width: 0, height: 0)
            
            LazyVStack {
                
                // Post
                VStack (alignment: .leading) {
                    HStack {
                        AuthorNameView(name: self.postAuthor, postId: self.postId)
                        ContributedView(contributed: self.contributed)
                        Spacer()
                        LolView(lols: self.lols)
                    }
                    .padding(.bottom, 2)
                    
                    HStack {
                        Text(postBody)
                            .font(.footnote)
                    }
                
                }
                .padding()
                .background(Color("ThreadBubblePrimary"))
                .cornerRadius(5)
                
                // Replies
                if self.replies.count > 0 {
                    ForEach(self.replies, id: \.id) { reply in
                        watchOSPostPreview(postId: .constant(reply.id), replyText: .constant(String(reply.body.getPreview.prefix(100))))
                    }
                }
                
            }
            
        }
        .onAppear(perform: getThreadData)
    }
}

struct watchOsPostDetail_Previews: PreviewProvider {
    static var previews: some View {
        watchOsPostDetail(postId: .constant(9999999992))
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
            .environmentObject(AppSessionStore())
            .environmentObject(ChatStore(service: ChatService()))
    }
}
