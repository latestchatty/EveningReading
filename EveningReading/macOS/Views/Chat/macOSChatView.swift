//
//  macOSChatView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/10/21.
//

import SwiftUI

struct macOSChatView: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService
    
    @State private var showingGuidelinesView = false
    @State private var guidelinesAccepted = false
    
    private func getChat() {
        if chatService.threads.count > 0
        {
            return
        }
        chatService.getChat()
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack (alignment: .top, spacing: 0) {
                    
                // Check if guidelines accepted
                Spacer().frame(width: 0, height: 0)
                .onAppear() {
                    DispatchQueue.main.async {
                        self.showingGuidelinesView = !appService.didAcceptGuidelines()
                    }
                }
                .navigationTitle("Chat")

                // New post
                macOSComposePostView()
                
                // Report user
                macOSReportUserView()
                
                // Guidelines
                if self.showingGuidelinesView {
                    macOSGuidelinesView(showingGuidelinesView: $showingGuidelinesView, guidelinesAccepted: self.$guidelinesAccepted)
                }
                
                // Thread and posts etc...
                if !self.showingGuidelinesView {
                    
                    // Thread List
                    ScrollView {
                        ScrollViewReader { scrollProxy in
                            Spacer().frame(width: 1, height: 1)
                            .id(ScrollToTopId)
                            LazyVStack (spacing: 0) {
                                macOSThreadList()
                            }
                            .onReceive(chatService.$didGetChatStart) { value in
                                if value {
                                    scrollProxy.scrollTo(ScrollToTopId, anchor: .top)
                                    chatService.didGetChatStart = false
                                }
                            }
                            Spacer().frame(width: 1, height: 12)
                            .id(ScrollToBottomId)
                        }
                    }
                    .frame(width: geometry.size.width * 0.35)
                    .disabled(chatService.showingNewPostSpinner || chatService.showingRefreshThreadSpinner)
                    .scrollDisabled(chatService.showingNewPostSpinner || chatService.showingRefreshThreadSpinner)
                    
                    Divider()
                    
                    // Thread Detail
                    ZStack {
                        
                        // Thread Detail
                        ScrollView {
                            ScrollViewReader { scrollProxy in
                                Spacer().frame(width: 1, height: 1)
                                .id(ScrollToTopId)
                                LazyVStack {
                                    if chatService.activeThreadId == 0 {
                                        if !chatService.postingNewThread {
                                            Text("No thread selected.")
                                                .font(.body)
                                                .bold()
                                                .foregroundColor(Color("NoDataLabel"))
                                                .padding(.top, 10)
                                        }
                                    } else {
                                        macOSThreadView(threadId: $chatService.activeThreadId)
                                    }
                                }
                                .onReceive(chatService.$activeThreadId) { value in
                                    scrollProxy.scrollTo(ScrollToTopId, anchor: .top)
                                }
                                .onReceive(chatService.$scrollTargetChat) { value in
                                    scrollProxy.scrollTo(value)
                                }
                                .onReceive(chatService.$shouldScrollThreadToTop) { value in
                                    if value {
                                        scrollProxy.scrollTo(ScrollToTopId, anchor: .top)
                                        chatService.shouldScrollThreadToTop = false
                                    }
                                }
                            }
                        }
                        .disabled(chatService.showingNewPostSpinner || chatService.showingRefreshThreadSpinner)
                        .scrollDisabled(chatService.showingNewPostSpinner || chatService.showingRefreshThreadSpinner)
                        
                        // Toasts
                        NoticeView(show: $chatService.showingTagNotice, message: chatService.taggingNoticeText)
                        
                        NoticeView(show: $chatService.didCopyLink, message: "Copied!")
                        
                    }
                    .frame(width: geometry.size.width * 0.65)

                }
            }
            .overlay(
                LoadingView(show: $chatService.showingNewPostSpinner)
            )
            .overlay(
                LoadingView(show: $chatService.showingRefreshThreadSpinner)
            )
            .onAppear(perform: getChat)
            .onReceive(chatService.$showingNewPostSpinner) { value in
                if value {
                    chatService.newReplyAuthorName = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(8)) {
                        chatService.showingNewPostSpinner = false
                        if chatService.newPostParentId == 0 {
                            chatService.getChat()
                        } else {
                            chatService.getThread()
                        }
                        chatService.newPostParentId = 0
                        chatService.postingNewThread = false
                    }
                }
            }
        }
    }
}
