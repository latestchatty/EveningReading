//
//  TrendingView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct TrendingView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var viewedPostsStore: ViewedPostsStore
    
    @State private var showPlaceholder = true
    @State private var selectedThreadId: Int? = 0
    
    private var threadLimit = 6

    private func navigateTo(_ goToDestination: inout Bool) {
        appSessionStore.resetNavigation()
        goToDestination = true
    }
    
    private func fetchChat() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil || chatStore.threads.count > 0
        {
            return
        }
        self.viewedPostsStore.getViewedPosts()
        self.chatStore.getChat(viewedPostsStore: self.viewedPostsStore)
    }
    
    private func filteredThreads() -> [ChatThread] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            return Array(chatData.threads.prefix(4))
        }
        let threads = self.chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)}).sorted(by: { $0.posts.count > $1.posts.count }).prefix(self.threadLimit)
        if threads.count > 0 {
            return Array(threads.prefix(self.threadLimit))
        } else {
            return Array(chatData.threads.prefix(self.threadLimit))
        }
    }
    
    var body: some View {
        VStack {
            // Heading
            VStack {
                HStack {
                    Text("Trending")
                        .font(.title2)
                        .fontWeight(.heavy)
                    Spacer()
                }
                .padding(.horizontal, UIScreen.main.bounds.width <= 375 ? 35 : 20)
            }
            .padding(.top, 20)
            
            // Content
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(filteredThreads(), id: \.threadId) { thread in
                            NavigationLink(destination: ThreadDetailView(threadId: .constant(thread.threadId), postId: .constant(0), replyCount: .constant(thread.posts.count - 1), isSearchResult: .constant(false)), tag: thread.threadId, selection: $selectedThreadId) { EmptyView() }
                            TrendingCard(thread: .constant(thread))
                            .conditionalModifier(thread.threadId, RedactedModifier())
                            .background(Color.clear)
                            .padding(.trailing, 33)
                            .onTapGesture(count: 1) {
                                self.selectedThreadId = thread.threadId
                            }
                        }
                    }.padding(40)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 480)
                Spacer()
            }
            .padding(.top, -20)
        }
        .onAppear(perform: fetchChat)
    }
}
struct TrendingView_Previews: PreviewProvider {
    static var previews: some View {
        TrendingView()
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
