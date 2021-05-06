//
//  ThreadDetailView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct ThreadDetailView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    @Binding var threadId: Int
    
    @State private var rootPostCategory: String = "ontopic"
    @State private var rootPostAuthor: String = ""
    @State private var rootPostBody: String = ""
    @State private var rootPostDate: String = "2020-08-14T21:05:00Z"
    @State private var rootPostLols: [ChatLols] = [ChatLols]()
    @State private var contributed: Bool = false
    @State private var showThread: Bool = false
    
    private func getThreadData() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
                let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
                self.rootPostCategory = rootPost?.category ?? "ontopic"
                self.rootPostAuthor = rootPost?.author ?? ""
                self.rootPostBody = rootPost?.body.getPreview ?? ""
                self.rootPostDate = rootPost?.date ?? "2020-08-14T21:05:00Z"
                self.rootPostLols = rootPost?.lols ?? [ChatLols]()
                
                self.showThread = true
            } else {
                self.showThread = false
            }
        }
        if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
            let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
            self.rootPostCategory = rootPost?.category ?? "ontopic"
            self.rootPostAuthor = rootPost?.author ?? ""
            self.rootPostBody = rootPost?.body.getPreview ?? ""
            self.rootPostDate = rootPost?.date ?? "2020-08-14T21:05:00Z"
            self.rootPostLols = rootPost?.lols ?? [ChatLols]()
            
            self.showThread = true
        } else {
            self.showThread = false
        }
    }
    
    var body: some View {
        VStack {
            if self.showThread {
                
                RefreshableScrollView(height: 70, refreshing: self.$chatStore.loadingThread, scrollTarget: self.$chatStore.scrollTargetThread, scrollTargetTop: self.$chatStore.scrollTargetThreadTop) {
                        
                    // Root Post
                    VStack {
                        HStack (alignment: .center) {
                            AuthorNameView(name: self.rootPostAuthor, postId: self.threadId)

                            ContributedView(contributed: self.contributed)

                            Spacer()

                            if UIDevice.current.userInterfaceIdiom == .phone {
                                LolView(lols: self.rootPostLols)
                            }
                        }
                        .padding(.top, 10)
                        
                        VStack {
                            HStack () {
                                Text("\(self.rootPostBody)")
                                    .font(.body)
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                        }
                        .frame(maxWidth: .infinity)
                        .background(RoundedCornersView(color: Color("ChatBubblePrimary")))
                        .padding(.bottom, 10)
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
                    .id(9999999999991)
                    
                    // Replies
                    // TODO...
                    
                }
                
            }
        }
        .onAppear(perform: getThreadData)
        .onReceive(self.chatStore.$activeThreadId) { _ in
            if UIDevice.current.userInterfaceIdiom == .pad {
                getThreadData()
            }
        }
        .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle(UIDevice.current.userInterfaceIdiom == .pad ? "Chat" : "Thread", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 26, height: 16))
    }
}

struct ThreadDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ThreadDetailView(threadId: .constant(9999999992))
            .environmentObject(AppSessionStore())
            .environmentObject(ChatStore(service: ChatService()))
    }
}
