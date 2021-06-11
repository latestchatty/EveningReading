//
//  macOSThreadPreview.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/11/21.
//

import SwiftUI

struct macOSThreadPreview: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    var threadId: Int
    
    @State private var rootPostCategory: String = "ontopic"
    @State private var rootPostAuthor: String = ""
    @State private var rootPostBody: String = ""
    @State private var rootPostDate: String = "2020-08-14T21:05:00Z"
    @State private var rootPostLols: [ChatLols] = [ChatLols]()
    @State private var contributed: Bool = false
    @State private var replyCount: Int = 0
    
    private func getThreadData() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
                if let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first {
                    self.rootPostCategory = rootPost.category
                    self.rootPostAuthor = rootPost.author
                    self.rootPostBody = rootPost.body.getPreview
                    self.rootPostDate = rootPost.date
                    self.rootPostLols = rootPost.lols
                }
                self.replyCount = thread.posts.count - 1
                
            }
        } else {
            let threads = chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
            
            if let thread = threads.filter({ return $0.threadId == self.threadId }).first {
                self.contributed = PostDecorator.checkParticipatedStatus(thread: thread, author: self.rootPostAuthor)
                if let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first {
                    self.rootPostCategory = rootPost.category
                    self.rootPostAuthor = rootPost.author
                    self.rootPostBody = rootPost.body.getPreview
                    self.rootPostDate = rootPost.date
                    self.rootPostLols = rootPost.lols
                }
                self.replyCount = thread.posts.count - 1
            }
        }
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                AuthorNameView(name: self.rootPostAuthor, postId: self.threadId, bold: true)
                
                ContributedView(contributed: self.contributed)

                Spacer()

                LolView(lols: self.rootPostLols, expanded: false, capsule: false, postId: self.threadId)

                ReplyCountView(replyCount: self.replyCount)
                
                TimeRemainingIndicator(percent: .constant(self.rootPostDate.getTimeRemaining()))
                    .frame(width: 12, height: 12)
                    .padding(.horizontal, 2)
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            
            // Root post body
            VStack (alignment: .leading) {
                Text(self.rootPostBody)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
            }
            .padding(.horizontal, 10)
            
            Divider()
                .frame(height: 1)
        }
        .contentShape(Rectangle())
        .background(self.contributed ? (chatStore.activeThreadId == self.threadId ? Color("ChatBubbleSecondaryContributed") : Color("ChatBubblePrimaryContributed")) : (chatStore.activeThreadId == self.threadId ? Color("ChatBubbleSecondary") : Color.clear))
        .onAppear(perform: getThreadData)
        .onTapGesture(count: 1) {
            chatStore.activeThreadId = self.threadId
        }
    }
}

struct macOSThreadPreview_Previews: PreviewProvider {
    static var previews: some View {
        macOSThreadPreview(threadId: 999999992)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
