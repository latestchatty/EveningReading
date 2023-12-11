//
//  TrendingView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct TrendingView: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService
    
    @State private var showPlaceholder = true
    @State private var selectedThreadId: Int? = 0
    
    private var threadLimit = 6

    private func navigateTo(_ goToDestination: inout Bool) {
        appService.resetNavigation()
        goToDestination = true
    }
    
    private func getChat() {
        if chatService.threads.count > 0
        {
            return
        }
        chatService.getChat()
    }
    
    private func filteredThreads() -> [ChatThread] {
        let threads = chatService.threads.filter({ return appService.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !appService.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)}).sorted(by: { $0.posts.count > $1.posts.count }).prefix(self.threadLimit)
        if threads.count > 0 {
            return Array(threads.prefix(self.threadLimit))
        } else {
            return Array(RedactedContentLoader.getChat().threads.prefix(self.threadLimit))
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
                            NavigationLink(destination: ThreadDetailView(threadId: thread.threadId, postId: 0, replyCount: thread.posts.count - 1), tag: thread.threadId, selection: $selectedThreadId) { EmptyView() }
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
            .padding(.top, -40)
        }
        .onAppear(perform: getChat)
    }
}

