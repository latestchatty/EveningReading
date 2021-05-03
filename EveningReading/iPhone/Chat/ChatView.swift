//
//  ChatView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatStore: ChatStore
    
    private func filteredThreads() -> [ChatThread] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            return Array(chatData.threads)
        }
        return Array(chatData.threads)
    }
    
    var body: some View {
        VStack {
            RefreshableScrollView(height: 70, refreshing: self.$chatStore.loadingChat, scrollTarget: self.$chatStore.scrollTargetChat, scrollTargetTop: self.$chatStore.scrollTargetChatTop) {
                
                ForEach(filteredThreads(), id: \.threadId) { thread in
                    ChatRow(threadId: .constant(thread.threadId))
                        .environmentObject(AppSessionStore())
                        .environmentObject(ChatStore(service: ChatService()))
                }
                
                VStack {
                    Spacer().frame(maxWidth: .infinity).frame(height: 30)
                }.id(9999999999993)

            }
        }
        .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Chat", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 26, height: 16))
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .environment(\.colorScheme, .dark)
            .environmentObject(ChatStore(service: ChatService()))
    }
}
