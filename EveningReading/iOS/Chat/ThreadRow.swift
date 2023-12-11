//
//  ThreadRow.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct ThreadRow: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore

    @Binding var threadId: Int
    @Binding var activeThreadId: Int

    @State private var rootPostCategory: String = "ontopic"
    @State private var rootPostAuthor: String = ""
    @State private var rootPostBodyPreview: String = ""
    @State private var rootPostBody: String = ""
    @State private var rootPostDate: String = "2020-08-14T21:05:00Z"
    @State private var rootPostLols: [ChatLols] = [ChatLols]()
    @State private var contributed: Bool = false
    @State private var replyCount: Int = 0
    @State private var lolTypeCount: Int = 0

    @State private var collapseThread: Bool = false

    @State private var showingWhosTaggingView = false
    
    @State private var showingNewMessageView = false
    @State private var messageRecipient: String = ""
    @State private var messageSubject: String = ""
    @State private var messageBody: String = ""
    
    @State private var favoriteContributed: Bool = false
    
    private func getThreadData() {
        if let currentThread = chatStore.threads.filter({ return $0.threadId == self.threadId }).first {
            setThreadData(currentThread)
            self.contributed = PostDecorator.checkParticipatedStatus(thread: currentThread, author: self.rootPostAuthor)
        }        
    }
    
    private func setThreadData(_ currentThread: ChatThread) {
        if let rootPost = currentThread.posts.filter({ return $0.parentId == 0 }).first {
            self.rootPostCategory = rootPost.category
            self.rootPostAuthor = rootPost.author
            self.rootPostBodyPreview = rootPost.body.getPreview
            self.rootPostBody = rootPost.body
            self.rootPostDate = rootPost.date
            self.rootPostLols = rootPost.lols
            self.replyCount = currentThread.posts.count - 1
        }
        for post in currentThread.posts {
            if appSessionStore.favoriteAuthors.contains(post.author) {
                self.favoriteContributed = true
            }
        }
    }
    
    var body: some View {
        if !self.collapseThread {
            if UIDevice.current.userInterfaceIdiom == .phone {
                // NavLink for iPhone
                NavigationLink(destination: ThreadDetailView(threadId: self.threadId, postId: 0, replyCount: self.replyCount)) {
                    self.threadRowDetail
                }.isDetailLink(false)
            } else {
                // No NavLink needed on iPad, uses chatStore.activeThreadId
                self.threadRowDetail
            }
        } else {
            EmptyView()
        }
    }
    
    private var threadRowDetail: some View {
        ZStack {
            // Category Color
            HStack {
                GeometryReader { categoryGeo in
                    Path { categoryPath in
                        categoryPath.move(to: CGPoint(x: 0, y: 19))
                        categoryPath.addLine(to: CGPoint(x: 0, y: categoryGeo.size.height - 15))
                        categoryPath.addLine(to: CGPoint(x: categoryGeo.size.width, y: categoryGeo.size.height - 15))
                        categoryPath.addLine(to: CGPoint(x: categoryGeo.size.width, y: 19))
                    }
                    .fill(ThreadCategoryColor[self.rootPostCategory]!)
                }
                .frame(width: 3)
                Spacer()
            }
        
            // Author, Contribution, Lols, Replies, Time, Preview
            VStack {
                HStack (alignment: .center) {
                    WhosTaggingView(showingWhosTaggingView: self.$showingWhosTaggingView)
                    
                    NewMessageView(showingNewMessageSheet: self.$showingNewMessageView, messageId: 0, recipientName: self.messageRecipient, subjectText: self.messageSubject, bodyText: self.messageBody)
                    
                    AuthorNameView(name: appSessionStore.blockedAuthors.contains(self.rootPostAuthor) ? "[blocked]" : self.rootPostAuthor, postId: self.threadId)

                    ContributedView(contributed: self.contributed)
                    
                    FavoriteContributedView(contributed: self.$favoriteContributed)

                    Spacer()

                    LolView(lols: self.rootPostLols, expanded: false, postId: self.threadId)

                    ReplyCountView(replyCount: self.replyCount)
                    
                    TimeRemainingIndicator(percent: .constant(self.rootPostDate.getTimeRemaining()))
                            .frame(width: 10, height: 10)
                }
                
                // Post Preview
                ZStack {
                    HStack (alignment: .top) {
                        Text(appSessionStore.blockedAuthors.contains(self.rootPostAuthor) ? "[blocked]" : rootPostBodyPreview)
                            .font(.callout)
                            .foregroundColor(Color(UIColor.label))
                            .lineLimit(appSessionStore.abbreviateThreads ? 3 : 8)
                            .multilineTextAlignment(.leading)
                            .frame(minHeight: 30)
                            .padding(10)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.callout)
                            .foregroundColor(Color(UIColor.systemGray))
                            .padding(.trailing, 20)
                                .padding(.top, 17)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(RoundedCornersView(color: (self.contributed ? (self.activeThreadId == self.threadId ? Color("ChatBubbleSecondaryContributed") : Color("ChatBubblePrimaryContributed")) : (self.activeThreadId == self.threadId ? Color("ChatBubbleSecondary") : Color("ChatBubblePrimary")))))
                .offset(y: -5)
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 10)
        }
        
        // Actions
        .contextMenu {
            PostContextView(showingWhosTaggingView: self.$showingWhosTaggingView, showingNewMessageView: self.$showingNewMessageView, messageRecipient: self.$messageRecipient, messageSubject: self.$messageSubject, messageBody: self.$messageBody, collapsed: self.$collapseThread, author: self.rootPostAuthor, postId: self.threadId, threadId: self.threadId, postBody: self.rootPostBody, showCopyPost: false)
        }
        
        // Load thread data
        .onAppear(perform: getThreadData)
        .onReceive(chatStore.$didGetChatFinish) { value in
            getThreadData()
        }
    }
}
