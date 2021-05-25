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
    
    @State private var isGettingChat: Bool = false
    
    private func filteredThreads() -> [ChatThread] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            return Array(chatData.threads)
        }
        let threads = chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        return Array(threads)
    }
        
    private func selectThreadById(threadId: Int) {
        chatStore.activeThreadId = threadId
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            GoToPostView(currentViewName: "ChatView")
            
            HStack (alignment: .top, spacing: 0) {
                
                // Navigation
                VStack {
                    RefreshableScrollView(height: 70, refreshing: self.$chatStore.gettingChat, scrollTarget: self.$chatStore.scrollTargetChat, scrollTargetTop: self.$chatStore.scrollTargetChatTop) {
                        
                        // All non-hidden threads
                        ForEach(filteredThreads(), id: \.threadId) { thread in
                            ThreadRow(threadId: .constant(thread.threadId), activeThreadId: $chatStore.activeThreadId)
                                .environmentObject(appSessionStore)
                                .environmentObject(chatStore)
                                .onTapGesture(count: 1) {
                                    selectThreadById(threadId: thread.threadId)
                                }
                                .padding(.bottom, -25)
                                .id(thread.threadId)
                        }
                        
                        // Scroll to bottom / padding
                        VStack {
                            Spacer().frame(maxWidth: .infinity).frame(height: 30)
                        }.id(9999999999993)
                    }
                }
                .frame(width: geometry.size.width * 0.35)
                
                Divider()
                
                // Detail
                VStack {
                    if chatStore.activeThreadId > 0 {
                        ThreadDetailView(threadId: $chatStore.activeThreadId, postId: .constant(0), replyCount: .constant(-1), isSearchResult: .constant(false))
                            .environmentObject(appSessionStore)
                            .environmentObject(chatStore)
                    } else {
                        Spacer()
                        HStack {
                            Text("No thread selected.")
                                .font(.body)
                                .bold()
                                .foregroundColor(Color("NoDataLabel"))
                        }
                        Spacer()
                    }
                }
                .frame(width: geometry.size.width * 0.65)
                
            }

        }
        
        // View settings
        .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Chat", displayMode: .inline)
        
        // New thread button
        .navigationBarItems(leading: Spacer().frame(width: 26, height: 16), trailing: ComposePostView(isRootPost: true))        
    }
}

struct iPadChatView_Previews: PreviewProvider {
    static var previews: some View {
        iPadChatView()
            .environment(\.colorScheme, .dark)
            .previewDevice(PreviewDevice(rawValue: "iPad (8th generation)"))
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
        
    }
}
