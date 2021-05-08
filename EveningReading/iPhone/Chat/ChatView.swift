//
//  ChatView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.colorScheme) var colorScheme
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
        VStack {
            RefreshableScrollView(height: 70, refreshing: self.$chatStore.loadingChat, scrollTarget: self.$chatStore.scrollTargetChat, scrollTargetTop: self.$chatStore.scrollTargetChatTop) {
                
                ForEach(filteredThreads(), id: \.threadId) { thread in
                    NavigationLink(destination: ThreadDetailView(threadId: .constant(thread.threadId)).environmentObject(appSessionStore).environmentObject(chatStore)) {
                        ThreadRow(threadId: .constant(thread.threadId), activeThreadId: .constant(0))
                            .environmentObject(appSessionStore)
                            .environmentObject(chatStore)
                    }
                    .padding(.bottom, -10)
                    .id(thread.threadId)
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
        .navigationBarItems(leading: Spacer().frame(width: 26, height: 16), trailing: ComposePostView(isRootPost: true))
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
