//
//  watchOSThreadRow.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct watchOSThreadRow: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    @Binding var threadId: Int
    
    @State private var categoryWidth: CGFloat = 3
    @State private var rootPostCategory: String = "ontopic"
    @State private var rootPostAuthor: String = ""
    @State private var rootPostBodyPreview: String = ""
    @State private var rootPostDate: String = "2020-08-14T21:05:00Z"
    @State private var rootPostLols: [ChatLols] = [ChatLols]()
    @State private var contributed: Bool = false
    @State private var replyCount: Int = 0
    
    @State private var isThreadCollapsed: Bool = false
    @State private var showingCollapseAlert: Bool = false
    @State private var showingPost: Bool = false
    
    private func getThreadData() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
                setThreadData(thread)
            }
        } else {
            if let thread = chatStore.threads.filter({ return $0.threadId == self.threadId }).first {
                setThreadData(thread)
            }
        }
    }
    
    private func setThreadData(_ thread: ChatThread) {
        let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
        self.rootPostCategory = rootPost?.category ?? "ontopic"
        self.rootPostAuthor = rootPost?.author ?? ""
        self.rootPostBodyPreview = rootPost?.body.getPreview ?? ""
        self.rootPostDate = rootPost?.date ?? "2020-08-14T21:05:00Z"
        self.replyCount = thread.posts.count - 1
        self.rootPostLols = rootPost?.lols ?? [ChatLols]()
    }
    
    var body: some View {
        VStack {
            
            // Fixes navigation bug
            // https://developer.apple.com/forums/thread/677333
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.frame(width: 0, height: 0)
            
            if !self.isThreadCollapsed {
                VStack (alignment: .leading) {
                    // Thread details
                    HStack {
                        AuthorNameView(name: appSessionStore.blockedAuthors.contains(self.rootPostAuthor) ? "[blocked]" : self.rootPostAuthor, postId: self.threadId, navLink: true)
                        ContributedView(contributed: self.contributed)
                        Spacer()
                        LolView(lols: self.rootPostLols, postId: self.threadId)
                        ReplyCountView(replyCount: self.replyCount)
                    }
                    // Thread body preview
                    HStack {
                        Text(appSessionStore.blockedAuthors.contains(self.rootPostAuthor) ? "[blocked]" : rootPostBodyPreview)
                            .font(.footnote)
                            .lineLimit(3)
                            .onTapGesture(count: 1) {
                                self.showingPost.toggle()
                            }
                            .onLongPressGesture {
                                self.showingCollapseAlert.toggle()
                            }
                        NavigationLink(destination: watchOSPostDetail(postId: .constant(self.threadId)).environmentObject(appSessionStore).environmentObject(chatStore), isActive: self.$showingPost) {
                            EmptyView()
                        }.frame(width: 0, height: 0)
                        Spacer()
                    }
                }
                .padding()
                .background(Color("ThreadBubblePrimary"))
                .cornerRadius(5)
                .onAppear(perform: getThreadData)
            } else {
                Spacer()
            }
            
        }
        // Show when collapsing a thread
        .alert(isPresented: self.$showingCollapseAlert) {
            Alert(title: Text("Hide Thread?"), message: Text(""), primaryButton: .cancel(), secondaryButton: Alert.Button.default(Text("OK"), action: {
                self.isThreadCollapsed = true
                self.appSessionStore.collapsedThreads.append(threadId)
            }))
        }
        
    }
}

struct watchOSThreadRow_Previews: PreviewProvider {
    static var previews: some View {
        watchOSThreadRow(threadId: .constant(999999992))
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
