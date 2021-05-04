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
    
    private func filteredThreads() -> [ChatThread] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            return Array(chatData.threads)
        }
        return Array(chatData.threads)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack (alignment: .leading) {
                ForEach(filteredThreads(), id: \.threadId) { thread in
                    watchOSThreadRow(threadId: .constant(thread.threadId))
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        watchOSContentView()
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
            .environmentObject(AppSessionStore())
            .environmentObject(ChatStore(service: ChatService()))
    }
}
