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
    
    private func filteredThreads() -> [ChatThread] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            return Array(chatData.threads)
        }
        let threads = chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        return Array(threads)
    }
    
    var body: some View {
        ScrollView {
            VStack (spacing: 0) {
                ForEach(filteredThreads(), id: \.threadId) { thread in
                    macOSThreadPreview(threadId: thread.threadId)
                }
            }
        }
        .toolbar() {
            ToolbarItemGroup(placement: .navigation) {
                Button(action: {
                    // refresh
                    chatStore.activeThreadId = 0
                    chatStore.activePostId = 0
                    chatStore.getChat()
                }, label: {
                    Image(systemName: "arrow.counterclockwise")
                })
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
