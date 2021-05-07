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
                let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
                self.rootPostCategory = rootPost?.category ?? "ontopic"
                self.rootPostAuthor = rootPost?.author ?? ""
                self.rootPostBodyPreview = rootPost?.body.getPreview ?? ""
                self.rootPostDate = rootPost?.date ?? "2020-08-14T21:05:00Z"
                self.replyCount = thread.posts.count - 1
                self.rootPostLols = rootPost?.lols ?? [ChatLols]()
            }
        } else {
            if let thread = chatStore.threads.filter({ return $0.threadId == self.threadId }).first {
                let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
                self.rootPostCategory = rootPost?.category ?? "ontopic"
                self.rootPostAuthor = rootPost?.author ?? ""
                self.rootPostBodyPreview = rootPost?.body.getPreview ?? ""
                self.rootPostDate = rootPost?.date ?? "2020-08-14T21:05:00Z"
                self.replyCount = thread.posts.count - 1
                self.rootPostLols = rootPost?.lols ?? [ChatLols]()
            }
        }
    }
    
    var body: some View {
        VStack {
            
            // Fixes SwiftUI/watchOS/simulator navigation bug?
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.frame(width: 0, height: 0)
            
            if !self.isThreadCollapsed {
                VStack (alignment: .leading) {
                    HStack {
                        AuthorNameView(name: self.rootPostAuthor, postId: self.threadId, bold: false)
                        ContributedView(contributed: self.contributed)
                        Spacer()
                        LolView(lols: self.rootPostLols)
                        ReplyCountView(replyCount: self.replyCount)
                    }
                    HStack {
                        Text(rootPostBodyPreview)
                            .font(.footnote)
                            .lineLimit(3)
                            .onTapGesture(count: 1) {
                                self.showingPost.toggle()
                            }
                            .onLongPressGesture {
                                self.showingCollapseAlert.toggle()
                            }
                        NavigationLink(destination: watchOsPostDetail(postId: .constant(self.threadId)).environmentObject(chatStore), isActive: self.$showingPost) {
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
        .alert(isPresented: self.$showingCollapseAlert) {
            Alert(title: Text("Hide Thread?"), message: Text(""), primaryButton: .cancel(), secondaryButton: Alert.Button.default(Text("OK"), action: {
                self.isThreadCollapsed = true
            }))
        }
    }
}

struct watchOSThreadRow_Previews: PreviewProvider {
    static var previews: some View {
        watchOSThreadRow(threadId: .constant(999999992))
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
            .environmentObject(AppSessionStore())
            .environmentObject(ChatStore(service: ChatService()))
    }
}
