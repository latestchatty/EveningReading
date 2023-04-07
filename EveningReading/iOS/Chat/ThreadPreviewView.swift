//
//  ThreadPreviewView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/31/21.
//

// Used by ChatViewPreloaded

import SwiftUI

struct ThreadPreviewView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore

    @Binding var activeThreadId: Int

    var rootPost: ChatPosts
    var rootPostBodyPreview: String
    var rootPostDate: Double
    var replyCount: Int
    var contributed: Bool
    
    @State private var rootPostsBody: [Int : String] = [:]
    @State private var rootPostsDate: [Int : Double] = [:]
    @State private var rootPostsReplyCount: [Int : Int] = [:]

    @State private var lolTypeCount: Int = 0

    @State private var collapseThread: Bool = false

    @State private var showingWhosTaggingView = false
    
    @State private var showingNewMessageView = false
    @State private var messageRecipient: String = ""
    @State private var messageSubject: String = ""
    @State private var messageBody: String = ""
        
    var body: some View {
        if !self.collapseThread {
            if UIDevice.current.userInterfaceIdiom == .phone {
                // NavLink for iPhone
                NavigationLink(destination: ThreadDetailView(threadId: .constant(self.rootPost.threadId), postId: .constant(0), replyCount: .constant(self.replyCount), isSearchResult: .constant(false))) {
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
                        categoryPath.move(to: CGPoint(x: 0, y: 18))
                        categoryPath.addLine(to: CGPoint(x: 0, y: categoryGeo.size.height - 18))
                        categoryPath.addLine(to: CGPoint(x: categoryGeo.size.width, y: categoryGeo.size.height - 18))
                        categoryPath.addLine(to: CGPoint(x: categoryGeo.size.width, y: 18))
                    }
                    .fill(ThreadCategoryColor[self.rootPost.category]!)
                }
                .frame(width: 3)
                Spacer()
            }
            
            // Author, Contribution, Lols, Replies, Time, Preview
            VStack {
                
                HStack (alignment: .center) {
                    WhosTaggingView(showingWhosTaggingView: self.$showingWhosTaggingView)
                    
                    NewMessageView(showingNewMessageSheet: self.$showingNewMessageView, messageId: Binding.constant(0), recipientName: self.$messageRecipient, subjectText: self.$messageSubject, bodyText: self.$messageBody)
                    
                    AuthorNameView(name: appSessionStore.blockedAuthors.contains(self.rootPost.author) ? "[blocked]" : self.rootPost.author, postId: self.rootPost.threadId)

                    ContributedView(contributed: self.contributed)

                    Spacer()

                    LolView(lols: self.rootPost.lols, expanded: true, postId: self.rootPost.threadId)

                    ReplyCountView(replyCount: self.replyCount)
                    
                    TimeRemainingIndicator(percent: .constant(self.rootPostDate))
                            .frame(width: 10, height: 10)
                    
                }
                
                // Post Preview
                ZStack {
                    HStack (alignment: .top) {
                        Text(appSessionStore.blockedAuthors.contains(self.rootPost.author) ? "[blocked]" : self.rootPostBodyPreview)
                            .font(.callout)
                            .foregroundColor(Color(UIColor.label))
                            .lineLimit(appSessionStore.abbreviateThreads ? 3 : 8)
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
                .background(RoundedCornersView(color: (self.contributed ? (self.activeThreadId == self.rootPost.threadId ? Color("ChatBubbleSecondaryContributed") : Color("ChatBubblePrimaryContributed")) : (self.activeThreadId == self.rootPost.threadId ? Color("ChatBubbleSecondary") : Color("ChatBubblePrimary")))))
                .padding(.bottom, 5)
                
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            
        }
        
        // Actions
        .contextMenu {
            PostContextView(showingWhosTaggingView: self.$showingWhosTaggingView, showingNewMessageView: self.$showingNewMessageView, messageRecipient: self.$messageRecipient, messageSubject: self.$messageSubject, messageBody: self.$messageBody, collapsed: self.$collapseThread, author: self.rootPost.author, postId: self.rootPost.threadId, threadId: self.rootPost.threadId, postBody: self.rootPost.body, showCopyPost: false)
        }
        
    }
    
}

struct ThreadPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ThreadPreviewView(activeThreadId: .constant(999999992), rootPost: ChatPosts(id: 999999992, threadId: 999999992, parentId: 0, author: "tamzyn", category: "interesting", date: "2020-08-14T06:44:00Z", body: "", lols: [ChatLols(tag: "lol", count: 2)]), rootPostBodyPreview: "Est sit amet facilisis magna etiam tempor. Amet consectetur adipiscing elit duis tristique sollicitudin nibh sit amet. Sed cras ornare arcu dui. Nisl purus in mollis nunc sed id semper.", rootPostDate: 0, replyCount: 27, contributed: false)
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}

