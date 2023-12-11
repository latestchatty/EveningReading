//
//  macOSThreadList.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/11/21.
//

import SwiftUI

struct macOSThreadList: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService
    
    private func filteredThreads() -> [ChatThread] {
        let threads = chatService.threads.filter({ return self.appService.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appService.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId) && !self.appService.badWords.contains(where: $0.posts.filter({ return $0.parentId == 0 })[0].body.lowercased().components(separatedBy: " ").contains)})
        return Array(threads)
    }
    
    var body: some View {
        VStack {
            if chatService.gettingChat {
                ProgressView()
                    .foregroundColor(Color.accentColor)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
                Spacer()
            } else if chatService.postingNewThread {
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
