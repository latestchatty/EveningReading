//
//  ChatView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

// https://blckbirds.com/post/mastering-pull-to-refresh-in-swiftui/
// https://swift-cast.com/2020/10/1/

import SwiftUI

struct ChatView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore

    @State private var isGettingChat: Bool = false
    @State private var noInternet: Bool = false
    @State private var showingSearch: Bool = false
    @State private var searchTerms: String = ""
    @State private var searchPadding: Double = -100
    @State private var resultsPadding: Double = 1
    @State private var favoriteContributed: [Int] = [0]

    //@State private var isPushNotificationAlertShowing: Bool = false
    
    private func filteredThreads() -> [ChatThread] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            return Array(chatData.threads)
        }
        var threads = chatStore.threads
        
        if searchTerms != "" {
            threads = chatStore.threads.filter({ return
                $0.posts.filter({ return $0.parentId == 0  })[0].body.lowercased().contains(searchTerms.lowercased()) &&
            self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) &&
            !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        } else {
            threads = chatStore.threads.filter({ return
            self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) &&
            !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
        }        
        return Array(threads)
    }
    
    var body: some View {
        ZStack {
            VStack {
                // Comment out to preview
                //GoToPostView(currentViewName: "ChatView")
                
                // height: 70
                RefreshableScrollView(height: 70, refreshing: self.$chatStore.gettingChat, scrollTarget: self.$chatStore.scrollTargetChat, scrollTargetTop: self.$chatStore.scrollTargetChatTop) {
                    
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
                    }.id(9999999999991)
                    
                    // All non-hidden threads
                    ForEach(filteredThreads(), id: \.threadId) { thread in
                        ThreadRow(threadId: .constant(thread.threadId), activeThreadId: .constant(0))
                            .padding(.bottom, -20)
                            .id(thread.threadId)
                    }
                    
                    // Scroll to bottom / padding
                    VStack {
                        Spacer().frame(maxWidth: .infinity).frame(height: 30)
                    }.id(9999999999993)
                    
                }
                //.overlay(PushNotificationView(isAlertShowing: self.$isPushNotificationAlertShowing))
            }
            
            .overlay(NoticeView(show: $chatStore.showingFavoriteNotice, message: .constant("Added User!")))
            
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
        .overlay(LoadingView(show: self.$isGettingChat, title: .constant("")))
        
        .onReceive(chatStore.$didSubmitNewThread) { value in
            self.chatStore.scrollTargetChatTop = 9999999999991
            chatStore.didGetChatStart = false
            self.isGettingChat = true
        }
        
        // Fetching chat data
        .onReceive(chatStore.$didGetChatStart) { value in
            if value && self.chatStore.didSubmitPost {
                self.chatStore.scrollTargetChatTop = 9999999999991
                chatStore.didGetChatStart = false
                self.isGettingChat = true
                self.chatStore.gettingChat = true
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15)) {
                    chatStore.didGetChatFinish = true
                }
            }
        }
        
        // Finished getting chat data
        .onReceive(chatStore.$didGetChatFinish) { value in
            self.isGettingChat = false
            if chatStore.threads.isEmpty {
                self.noInternet = true
            } else {
                self.noInternet = false
            }
        }
        
        // Disable while getting new data
        .disabled(chatStore.gettingChat)
        
        // Reset active thread on iPhone
        .onAppear() {
            appSessionStore.currentViewName = "ChatView"
            if UIDevice.current.userInterfaceIdiom == .phone {
                chatStore.activeThreadId = 0
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
            .environmentObject(Notifications())
    }
}
