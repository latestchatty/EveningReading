//
//  macOSThreadList.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/11/21.
//

import SwiftUI

struct macOSThreadList: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var viewedPostsStore: ViewedPostsStore
    @State var showRootPostPrompt: Bool = false
    @State var gettingData: Bool = false
    
    private func filteredThreads() -> [ChatThread] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            return Array(chatData.threads)
        }
        
        // This is a lot of looping.
        //  It could probably be done at the time the chatty loads except in the case where you actively block something
        //  and want to see it immediately removed. Which is rare in comparison to how often this gets executed.
        print("Filtering threads for display")
        return chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
    }
    
    var body: some View {
        VStack {
            macOSTextPromptSheet(
                action: {text, handler in
                    chatStore.submitPost(postBody: text, postId: 0) { submitHandler in
                        switch submitHandler {
                        case .success(_):
                            handler(.success(true))
                            self.chatStore.getChat(viewedPostsStore: self.viewedPostsStore)
                        case .failure(let err):
                            handler(.failure(err))
                        }
                    }
                },
                label: {
                    EmptyView()
                },
                showPrompt: $showRootPostPrompt,
                title: "Write a root post",
                acceptButtonContent: "Post",
                useShackTagsInput: true)
            if self.gettingData || chatStore.gettingChat {
                ProgressView()
                    .foregroundColor(Color.accentColor)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
                
                Spacer()
            } else {
                ScrollView {
                    VStack (spacing: 0) {
                        ForEach(filteredThreads(), id: \.threadId) { thread in
                            macOSThreadPreview(threadId: thread.threadId)
                        }
                    }
                }
            }
        }
        .toolbar() {
            ToolbarItemGroup(placement: .navigation) {
                Button(action: {
                    // refresh
                    self.gettingData = true
                    let tx = Transaction(animation: .linear)
                    withTransaction(tx) {
                        if chatStore.activeThreadId != 0 {
                            if let thread = chatStore.threads.first(where: { return $0.threadId == chatStore.activeThreadId }) {
                                viewedPostsStore.markThreadViewed(thread: thread) { err in
                                    DispatchQueue.main.async {
                                        chatStore.getChat(viewedPostsStore: self.viewedPostsStore)
                                        self.gettingData = false
                                    }
                                }
                            }
                        } else {
                            chatStore.getChat(viewedPostsStore: self.viewedPostsStore)
                            self.gettingData = false
                        }
                        chatStore.activeThreadId = 0
                        chatStore.activePostId = 0
                    }
                }, label: {
                    Image(systemName: "arrow.counterclockwise")
                })
                .disabled(chatStore.gettingChat)
                .keyboardShortcut("r", modifiers: [.command, .shift])
                Button(action: {
                    self.showRootPostPrompt = true
                }, label: {
                    Image(systemName: "square.and.pencil")
                })
            }
        }
    }
}

struct macOSThreadList_Previews: PreviewProvider {
    static var previews: some View {
        macOSThreadList()
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
            .environmentObject(ViewedPostsStore())
    }
}
