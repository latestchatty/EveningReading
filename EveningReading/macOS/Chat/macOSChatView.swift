//
//  macOSChatView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct macOSChatView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    @State var notificationCount: Int = 0
    @State var showingRefreshNotice: Bool = false
    
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
        let threads = chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        return Array(threads)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack (alignment: .leading) {
                ScrollViewReader { scrollProxy in
                    VStack {
                        Spacer().frame(maxWidth: .infinity).frame(height: 30)
                    }.id(9999999999991)
                    .onReceive(chatStore.$threads) { threads in
                        if threads.count < 1 {
                            scrollProxy.scrollTo(9999999999991)
                        }
                    }
                    ForEach(filteredThreads(), id: \.threadId) { thread in
                        FullThreadView(threadId: .constant(thread.threadId))
                    }
                    VStack {
                        Spacer().frame(maxWidth: .infinity).frame(height: 30)
                    }.id(9999999999993)
                }
            }
            .onAppear(perform: fetchChat)
        }
        .overlay(RefreshNoticeView(showingNotice: self.$showingRefreshNotice))
        .onReceive(chatStore.$loadingChat) { loading in
            // Don't show notification at launch
            if !loading && self.notificationCount > 2 {
                withAnimation {
                    self.showingRefreshNotice = true
                }
            }
            self.notificationCount += 1
        }
        .frame(maxHeight: .infinity)
        .navigationTitle("Chat")
    }
}

struct macOSChatView_Previews: PreviewProvider {
    static var previews: some View {
        macOSChatView()
            .previewLayout(.fixed(width: 640, height: 480))
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
