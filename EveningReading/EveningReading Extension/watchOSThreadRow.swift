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
    @State private var contributed: Bool = false
    @State private var replyCount: Int = 0
    @State private var hasLols: Bool = false
    @State private var lols = [String: Int]()
    @State private var lolTypeCount: Int = 0
    
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
                self.replyCount = thread.posts.count - 1
                
                for lol in rootPost?.lols ?? [ChatLols]() {
                    if lol.count > 0 {
                        self.hasLols = true
                    }
                    lols[String("\(lol.tag)")] = lol.count
                    if lol.count > 0 {
                        lolTypeCount += 1
                    }
                }
            }
        }
        if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
            let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
            self.rootPostCategory = rootPost?.category ?? "ontopic"
            self.rootPostAuthor = rootPost?.author ?? ""
            self.rootPostBodyPreview = rootPost?.body.getPreview ?? ""
            self.replyCount = thread.posts.count - 1
            
            for lol in rootPost?.lols ?? [ChatLols]() {
                if lol.count > 0 {
                    self.hasLols = true
                }
                lols[String("\(lol.tag)")] = lol.count
                if lol.count > 0 {
                    lolTypeCount += 1
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if !self.isThreadCollapsed {
                VStack (alignment: .leading) {
                    HStack {
                        AuthorNameView(name: .constant(self.rootPostAuthor), postId: self.$threadId)
                        ContributedView(contributed: .constant(self.contributed))
                        Spacer()
                        LolView(lols: self.$lols)
                        ReplyCountView(replyCount: self.$replyCount)
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
                        NavigationLink(destination: watchOsPostDetail(postId: .constant(self.threadId)), isActive: self.$showingPost) {
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
        watchOSThreadRow(threadId: .constant(9999999992))
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
            .environmentObject(AppSessionStore())
            .environmentObject(ChatStore(service: ChatService()))
    }
}
