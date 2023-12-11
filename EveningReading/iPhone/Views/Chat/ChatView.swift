//
//  ChatView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService

    @State private var isGettingChat: Bool = false
    @State private var noInternet: Bool = false
    @State private var showingSearch: Bool = false
    @State private var searchTerms: String = ""
    @State private var searchPadding: Double = -100
    @State private var resultsPadding: Double = 1
    @State private var favoriteContributed: [Int] = [0]

    private func filteredThreads() -> [ChatThread] {
        var threads = chatService.threads
        if searchTerms != "" {
            threads = chatService.threads.filter({ return
                $0.posts.filter({ return $0.parentId == 0  })[0].body.lowercased().contains(searchTerms.lowercased()) &&
            appService.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) &&
            !appService.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        } else {
            threads = chatService.threads.filter({ return
            appService.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) &&
            !appService.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        }        
        return Array(threads)
    }
    
    var body: some View {
        ZStack {
            VStack {
                RefreshableScrollView(height: 70, refreshing: self.$chatService.gettingChat, scrollTarget: self.$chatService.scrollTargetChat, scrollTargetTop: self.$chatService.scrollTargetChatTop) {
                    
                    // No Internet/Data
                    if self.noInternet {
                        Text("Oops! No Data.")
                            .foregroundColor(Color("NoData"))
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("NoDataLabel"), lineWidth: 1)
                            )
                            .padding(.top, 20)
                    }
                    
                    // Scroll to top
                    VStack {
                        Spacer().frame(maxWidth: .infinity).frame(height: self.resultsPadding)
                    }.id(ScrollToTopId)
                    
                    // All non-hidden threads
                    ForEach(filteredThreads(), id: \.threadId) { thread in
                        ThreadRow(threadId: .constant(thread.threadId), activeThreadId: .constant(0))
                            .padding(.bottom, -15)
                            .id(thread.threadId)
                    }
                    
                    // Scroll to bottom / padding
                    VStack {
                        Spacer().frame(maxWidth: .infinity).frame(height: 30)
                    }.id(ScrollToBottomId)
                    
                }
            }
            
            .overlay(NoticeView(show: $chatService.showingFavoriteNotice, message: "Added User!"))
            
            .overlay(NoticeView(show: $chatService.showingCopiedNotice, message: "Copied!"))
            
            if showingSearch {
                VStack {
                    TextField("Search for...", text: $searchTerms)
                        .padding()
                        .autocapitalization(.none)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(4.0)
                        .padding(EdgeInsets(top: self.searchPadding, leading: 20, bottom: 0, trailing: 20))
                        .shadow(color: Color("HomeButtonShadow"), radius: 10, x: 0, y: 10)
                    Spacer()
                }
            }
            
        }
        // View settings
        .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Chat", displayMode: .inline)
        
        // New thread button
        .navigationBarItems(leading: Spacer().frame(width: 26, height: 16), trailing: HStack {
                // Search
                Button(action: {
                    self.showingSearch = !self.showingSearch
                    withAnimation {
                        if self.showingSearch {
                            self.searchPadding = 10
                            self.resultsPadding = 70
                        } else {
                            self.searchPadding = -100
                            self.searchTerms = ""
                            self.resultsPadding = 1
                        }
                    }
                }) {
                Image(systemName: "magnifyingglass.circle")
                    .imageScale(.large)
                    .foregroundColor(self.colorScheme == .dark ? Color(UIColor.white) : Color(UIColor.systemBlue))
                }
                // Compose
                ComposePostView(isRootPost: true)
            })

        // If refreshing thread after posting
        .overlay(LoadingView(show: self.$isGettingChat))
        
        .onReceive(chatService.$didSubmitNewThread) { value in
            chatService.scrollTargetChatTop = ScrollToTopId
            chatService.didGetChatStart = false
            self.isGettingChat = true
        }
        
        // Fetching chat data
        .onReceive(chatService.$didGetChatStart) { value in
            if value && chatService.didSubmitPost {
                chatService.scrollTargetChatTop = ScrollToTopId
                chatService.didGetChatStart = false
                self.isGettingChat = true
                chatService.gettingChat = true
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15)) {
                    chatService.didGetChatFinish = true
                }
            }
        }
        
        // Finished getting chat data
        .onReceive(chatService.$didGetChatFinish) { value in
            self.isGettingChat = false
            if chatService.threads.isEmpty {
                self.noInternet = true
            } else {
                self.noInternet = false
            }
        }
        
        // Disable while getting new data
        .disabled(chatService.gettingChat)
        
        // Reset active thread on iPhone
        .onAppear() {
            if UIDevice.current.userInterfaceIdiom == .phone {
                chatService.activeThreadId = 0
            }
        }
    }
}
