//
//  macOSThreadList.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/11/21.
//

import SwiftUI

struct macOSThreadList: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var viewedPostsStore: ViewedPostsStore
    
    private func filteredThreads() -> [ChatThread] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            return Array(chatData.threads)
        }
        let threads = chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        return Array(threads)
    }
    
    var body: some View {
        VStack {
            if chatStore.gettingChat {
                // This feels jarring.
                // A better solution would be just animating the refresh button icon
                // I tried doing this, but the icon doesn't rotate on the center point of the circle
                // So it looks like it's bouncing when it's spinning. Maybe a different icon would work better?
                // For now we'll go with this.
                LoadingView(show: .constant(true), title: .constant("Loading threads"))
            } else {
                ScrollView {
                    VStack (spacing: 0) {
                        ForEach(filteredThreads(), id: \.threadId) { thread in
                            macOSThreadPreview(threadId: thread.threadId)
                        }
                    }
                }
            }
        }
        .toolbar() {
            ToolbarItemGroup(placement: .navigation) {
                Button(action: {
                    // refresh
                    if chatStore.activeThreadId != 0 {
                        if let thread = chatStore.threads.first(where: { return $0.threadId == chatStore.activeThreadId }) {
                            viewedPostsStore.markThreadViewed(thread: thread)
                        }
                    }
                    chatStore.activeThreadId = 0
                    chatStore.activePostId = 0
                    viewedPostsStore.syncViewedPosts()
                    chatStore.getChat()
                }, label: {
                    Image(systemName: "arrow.counterclockwise")
                })
                .disabled(chatStore.gettingChat)
                .keyboardShortcut("r", modifiers: [.command, .shift])
                Button(action: {
                    // compose
                }, label: {
                    Image(systemName: "square.and.pencil")
                })
            }
        }
    }
}

struct macOSThreadList_Previews: PreviewProvider {
    static var previews: some View {
        macOSThreadList()
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
