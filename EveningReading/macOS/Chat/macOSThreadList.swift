//
//  macOSThreadList.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/11/21.
//

import SwiftUI

struct macOSThreadList: View {
    @EnvironmentObject var appSession: AppSession
    @EnvironmentObject var chatStore: ChatStore
    
    private func filteredThreads() -> [ChatThread] {
        let threads = chatStore.threads.filter({ return self.appSession.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSession.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId) && !self.appSession.badWords.contains(where: $0.posts.filter({ return $0.parentId == 0 })[0].body.lowercased().components(separatedBy: " ").contains)})
        return Array(threads)
    }
    
    var body: some View {
        VStack {
            if chatStore.gettingChat {
                ProgressView()
                    .foregroundColor(Color.accentColor)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
                Spacer()
            } else if chatStore.postingNewThread {
                EmptyView()
            } else {
                ForEach(filteredThreads(), id: \.threadId) { thread in
                    macOSThreadPreview(threadId: thread.threadId)
                        .padding(.bottom, -10)
                }
            }
        }
    }
}
