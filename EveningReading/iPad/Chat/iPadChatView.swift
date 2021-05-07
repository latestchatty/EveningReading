//
//  iPadChatView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct iPadChatView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    private func filteredThreads() -> [ChatThread] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            return Array(chatData.threads)
        }
        let threads = chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        if threads.count > 0 {
            return Array(threads)
        } else {
            return Array(chatData.threads)
        }
    }
        
    private func selectThreadById(threadId: Int) {
        chatStore.activeThreadId = threadId
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack (alignment: .top, spacing: 0) {
                // Navigation
                VStack {
                    RefreshableScrollView(height: 70, refreshing: self.$chatStore.loadingChat, scrollTarget: self.$chatStore.scrollTargetChat, scrollTargetTop: self.$chatStore.scrollTargetChatTop) {
                        
                        ForEach(filteredThreads(), id: \.threadId) { thread in
                            ThreadRow(threadId: .constant(thread.threadId), activeThreadId: $chatStore.activeThreadId)
                                .environmentObject(appSessionStore)
                                .environmentObject(chatStore)
                                .onTapGesture(count: 1) {
                                    selectThreadById(threadId: thread.threadId)
                                }
                                .padding(.bottom, -10)
                                .id(thread.threadId)
                        }
                        
                        VStack {
                            Spacer().frame(maxWidth: .infinity).frame(height: 30)
                        }.id(9999999999993)
                    }
                }
                .frame(width: geometry.size.width * 0.35)
                
                Divider()
                
                // Detail
                VStack {
                    ThreadDetailView(threadId: $chatStore.activeThreadId)
                        .environmentObject(appSessionStore)
                        .environmentObject(chatStore)
                }
                .frame(width: geometry.size.width * 0.65)
            }
        }
        .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Chat", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 26, height: 16))
    }
}

struct iPadChatView_Previews: PreviewProvider {
    static var previews: some View {
        iPadChatView()
            .environment(\.colorScheme, .dark)
            .previewDevice(PreviewDevice(rawValue: "iPad (8th generation)"))
            .environmentObject(AppSessionStore())
            .environmentObject(ChatStore(service: ChatService()))
        
    }
}
