//
//  macOSChatView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/10/21.
//

import SwiftUI

struct macOSChatView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    @State private var showingGuidelinesView = false
    @State private var guidelinesAccepted = false
    
    private func fetchChat() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil || chatStore.threads.count > 0
        {
            return
        }
        chatStore.getChat()
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack (alignment: .top, spacing: 0) {
                    
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

                // New post
                macOSComposePostView()
                
                // Guidelines
                if self.showingGuidelinesView {
                    macOSGuidelinesView(showingGuidelinesView: $showingGuidelinesView, guidelinesAccepted: self.$guidelinesAccepted)
                }
                
                if self.guidelinesAccepted {
                    
                    // Thread List
                    ScrollView {
                        ScrollViewReader { scrollProxy in
                            Spacer().frame(width: 1, height: 1)
                            .id(999999991)
                            LazyVStack (spacing: 0) {
                                macOSThreadList()
                            }
                            .onReceive(chatStore.$didGetChatStart) { value in
                                if value {
                                    scrollProxy.scrollTo(999999991, anchor: .top)
                                    chatStore.didGetChatStart = false
                                }
                            }
                            Spacer().frame(width: 1, height: 12)
                            .id(999999992)
                        }
                    }
                    .frame(width: geometry.size.width * 0.35)
                    .disabled(chatStore.showingNewPostSpinner || chatStore.showingRefreshThreadSpinner)
                    
                    Divider()
                    
                    // Thread Detail
                    ZStack {
                        
                        // Thread Detail
                        ScrollView {
                            ScrollViewReader { scrollProxy in
                                Spacer().frame(width: 1, height: 1)
                                .id(999999991)
                                LazyVStack {
                                    if chatStore.activeThreadId == 0 {
                                        if !chatStore.postingNewThread {
                                            Text("No thread selected.")
                                                .font(.body)
                                                .bold()
                                                .foregroundColor(Color("NoDataLabel"))
                                                .padding(.top, 10)
                                        }
                                    } else {
                                        macOSThreadView(threadId: $chatStore.activeThreadId)
                                    }
                                }
                                .onReceive(chatStore.$activeThreadId) { value in
                                    scrollProxy.scrollTo(999999991, anchor: .top)
                                }
                                .onReceive(chatStore.$shouldScrollThreadToTop) { value in
                                    if value {
                                        scrollProxy.scrollTo(999999991, anchor: .top)
                                        chatStore.shouldScrollThreadToTop = false
                                    }
                                }
                            }
                        }
                        .disabled(chatStore.showingNewPostSpinner || chatStore.showingRefreshThreadSpinner)
                        
                        // Toasts
                        NoticeView(show: $chatStore.showingTagNotice, message: $chatStore.taggingNoticeText)
                        
                        NoticeView(show: $chatStore.didCopyLink, message: .constant("Copied!"))
                        
                    }
                    .frame(width: geometry.size.width * 0.65)

                }
            }
            .overlay(
                LoadingView(show: $chatStore.showingNewPostSpinner, title: .constant(""))
            )
            .overlay(
                LoadingView(show: $chatStore.showingRefreshThreadSpinner, title: .constant(""))
            )
            .onAppear(perform: fetchChat)
            .onReceive(chatStore.$showingNewPostSpinner) { value in
                if value {
                    chatStore.newReplyAuthorName = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(8)) {
                        chatStore.showingNewPostSpinner = false
                        if chatStore.newPostParentId == 0 {
                            chatStore.getChat()
                        } else {
                            chatStore.getThread()
                            //chatStore.hideReplies = true
                            //chatStore.shouldScrollThreadToTop = true
                            //chatStore.hideReplies = false
                        }
                        chatStore.newPostParentId = 0
                        chatStore.postingNewThread = false
                    }
                }
            }
        }
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
