//
//  ContentView.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 4/30/21.
//

import SwiftUI

struct watchOSContentView: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService
    
    @State private var showingGuidelinesView = true
    
    @ObservedObject private var watchService = WatchService.shared
    
    private func getChat() {
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
        ScrollView {
            ScrollViewReader { scrollProxy in
                
                Spacer().frame(width: 0, height: 0).id(ScrollToTopId)
                
                // Guidelines on first run
                watchOSGuidelines(showingGuidelinesView: $showingGuidelinesView)
                    .environmentObject(appService)
                    .onAppear() {
                        DispatchQueue.main.async {
                            self.showingGuidelinesView = !appService.didAcceptGuidelines()
                        }
                    }
                    .onChange(of: showingGuidelinesView) { value in
                        scrollProxy.scrollTo(ScrollToTopId, anchor: .top)
                    }
                
                // Thread list
                if !showingGuidelinesView {
                    if filteredThreads().count > 0 {
                        Button(action: {
                            chatService.getChat()
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
                                    .environmentObject(appService)
                                    .environmentObject(chatService)
                            }
                        }
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.top, 10)
                    }
                }
            }
        }
        .onAppear(perform: getChat)
    }
}
