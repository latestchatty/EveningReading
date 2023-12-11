//
//  macOSChatViewOld.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct macOSChatViewOld: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService
    
    @State private var showingGuidelinesView = false
    @State private var guidelinesAccepted = false
    
    private func fetchChat() {
        if chatService.threads.count > 0
        {
            return
        }
        chatService.getChat()
    }
    
    private func filteredThreads() -> [ChatThread] {
        let threads = chatService.threads.filter({ return appService.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !appService.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        return Array(threads)
    }
    
    var body: some View {
        
        // Check if guidelines accepted
        Spacer().frame(width: 0, height: 0)
        .onAppear() {
            DispatchQueue.main.async {
                let defaults = UserDefaults.standard
                //defaults.removeObject(forKey: "GuidelinesAccepted")
                self.guidelinesAccepted = defaults.object(forKey: "GuidelinesAccepted") as? Bool ?? false
                self.showingGuidelinesView = !self.guidelinesAccepted
            }
        }
        .navigationTitle("Chat")

        
        // Guidelines
        if self.showingGuidelinesView {
            macOSGuidelinesView(showingGuidelinesView: $showingGuidelinesView, guidelinesAccepted: self.$guidelinesAccepted)
        }
        
        // Threads
        if self.guidelinesAccepted {
            ScrollView {
                LazyVStack (alignment: .leading) {
                    ScrollViewReader { scrollProxy in
                        VStack {
                            Spacer().frame(maxWidth: .infinity).frame(height: 30)
                        }.id(ScrollToTopId)
                        .onReceive(chatService.$threads) { threads in
                            if threads.count < 1 {
                                scrollProxy.scrollTo(ScrollToTopId, anchor: .top)
                            }
                        }
                        /*
                        .onReceive(chatService.$activeThreadId) { thread in
                            if thread != 0 {
                                scrollProxy.scrollTo(thread)
                            }
                        }
                        */
                        ForEach(filteredThreads(), id: \.threadId) { thread in
                            macOSThreadViewOld(threadId: .constant(thread.threadId))
                                .id(thread.threadId)
                        }
                        VStack {
                            Spacer().frame(maxWidth: .infinity).frame(height: 30)
                        }.id(ScrollToBottomId)
                    }
                }
                .onAppear(perform: fetchChat)
            }
            .frame(maxHeight: .infinity)
        }
    }
}
