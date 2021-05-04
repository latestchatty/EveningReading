//
//  macOSChatView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct macOSChatView: View {
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
                ScrollViewReader { scrollProxy in
                    VStack {
                        Spacer().frame(maxWidth: .infinity).frame(height: 30)
                    }.id(9999999999991)
                    ForEach(filteredThreads(), id: \.threadId) { thread in
                        FullThreadView(threadId: .constant(thread.threadId))
                    }
                    VStack {
                        Spacer().frame(maxWidth: .infinity).frame(height: 30)
                    }.id(9999999999993)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .navigationTitle("Chat")
    }
}

struct macOSChatView_Previews: PreviewProvider {
    static var previews: some View {
        macOSChatView()
            .environmentObject(ChatStore(service: ChatService()))
    }
}
