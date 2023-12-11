//
//  macOSChatViewOld.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct macOSChatViewOld: View {
    @EnvironmentObject var appSession: AppSession
    @EnvironmentObject var chatStore: ChatStore
    
    @State private var showingGuidelinesView = false
    @State private var guidelinesAccepted = false
    
    private func fetchChat() {
        if chatStore.threads.count > 0
        {
            return
        }
        chatStore.getChat()
    }
    
    private func filteredThreads() -> [ChatThread] {
        let threads = chatStore.threads.filter({ return self.appSession.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSession.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
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
                        }.id(9999999999991)
                        .onReceive(chatStore.$threads) { threads in
                            if threads.count < 1 {
                                scrollProxy.scrollTo(9999999999991, anchor: .top)
                            }
                        }
                        /*
                        .onReceive(chatStore.$activeThreadId) { thread in
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
                        }.id(9999999999993)
                    }
                }
                .onAppear(perform: fetchChat)
            }
            .frame(maxHeight: .infinity)
        }
    }
}
