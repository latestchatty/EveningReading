//
//  ContentView.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 4/30/21.
//

import SwiftUI

struct watchOSContentView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    private func fetchChat() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil || chatStore.threads.count > 0
        {
            return
        }
        chatStore.getChat()
    }
    
    private func filteredThreads() -> [ChatThread] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            return Array(chatData.threads)
        }
        let threads = self.chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        return Array(threads)
    }
    
    var body: some View {
        ScrollView {
            Button(action: {
                chatStore.getChat()
            }) {
                HStack {
                    Text("Refresh")
                        .font(.footnote)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding()
                }
            }
            if filteredThreads().count > 0 {
                LazyVStack (alignment: .leading) {
                    ForEach(filteredThreads(), id: \.threadId) { thread in
                        watchOSThreadRow(threadId: .constant(thread.threadId))
                    }
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.top, 10)
            }
        }
        .onAppear(perform: fetchChat)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        watchOSContentView()
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
