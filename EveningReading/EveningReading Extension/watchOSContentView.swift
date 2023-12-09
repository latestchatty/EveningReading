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
    
    @State private var showingGuidelinesView = false
    
    @ObservedObject private var watchService = WatchService.shared
    
    private func getChat() {
        if chatStore.threads.count > 0
        {
            return
        }
        chatStore.getChat()
    }
    
    private func filteredThreads() -> [ChatThread] {
        let threads = self.chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        return Array(threads)
    }
    
    var body: some View {
        ScrollView {
            
            /*
            Text("Username = \($watchService.username.wrappedValue)")
            */
            
            // Guidelines on first run
            watchOSGuidelines(showingGuidelinesView: $showingGuidelinesView)
            .onAppear() {
                DispatchQueue.main.async {
                    let defaults = UserDefaults.standard
                    let guidelinesAccepted = defaults.object(forKey: "GuidelinesAccepted") as? Bool ?? false
                    self.showingGuidelinesView = !guidelinesAccepted
                }
            }
            
            // Thread list
            if filteredThreads().count > 0 {
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
                LazyVStack (alignment: .leading) {
                    ForEach(filteredThreads(), id: \.threadId) { thread in
                        watchOSThreadRow(threadId: .constant(thread.threadId))
                            .environmentObject(appSessionStore)
                            .environmentObject(chatStore)
                    }
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.top, 10)
            }
            
        }
        .onAppear(perform: getChat)
    }
}
