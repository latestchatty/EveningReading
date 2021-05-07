//
//  ThreadRow.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct ThreadRow: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore

    @Binding var threadId: Int
    @Binding var activeThreadId: Int

    @State private var categoryWidth: CGFloat = 3
    @State private var rootPostCategory: String = "ontopic"
    @State private var rootPostAuthor: String = ""
    @State private var rootPostBodyPreview: String = ""
    @State private var rootPostDate: String = "2020-08-14T21:05:00Z"
    @State private var rootPostLols: [ChatLols] = [ChatLols]()
    @State private var contributed: Bool = false
    @State private var replyCount: Int = 0
    @State private var lolTypeCount: Int = 0

    @State private var collapseThread: Bool = false
    @State private var showingCollapseAlert: Bool = false
    @State private var isSwiping : Bool = false
    @State private var swipeScale : CGFloat = 0.0
    @State private var swipeOffset = CGSize.zero

    private func getThreadData() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
                let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
                self.rootPostCategory = rootPost?.category ?? "ontopic"
                self.rootPostAuthor = rootPost?.author ?? ""
                self.rootPostBodyPreview = rootPost?.body.getPreview ?? ""
                self.rootPostDate = rootPost?.date ?? "2020-08-14T21:05:00Z"
                self.rootPostLols = rootPost?.lols ?? [ChatLols]()
                self.replyCount = thread.posts.count - 1
            }
        } else {
            let threads = chatStore.threads.filter({ return self.appSessionStore.threadFilters.contains($0.posts.filter({ return $0.parentId == 0 })[0].category) && !self.appSessionStore.collapsedThreads.contains($0.posts.filter({ return $0.parentId == 0 })[0].threadId)})
            
            if let thread = threads.filter({ return $0.threadId == self.threadId }).first {
                let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
                self.rootPostCategory = rootPost?.category ?? "ontopic"
                self.rootPostAuthor = rootPost?.author ?? ""
                self.rootPostBodyPreview = rootPost?.body.getPreview ?? ""
                self.rootPostDate = rootPost?.date ?? "2020-08-14T21:05:00Z"
                self.rootPostLols = rootPost?.lols ?? [ChatLols]()
                self.replyCount = thread.posts.count - 1
            }
        }
    }
    
    var body: some View {
        if !self.collapseThread {
            ZStack {
                // Category Color
                HStack {
                    GeometryReader { categoryGeo in
                        Path { categoryPath in
                            categoryPath.move(to: CGPoint(x: 0, y: 0))
                            categoryPath.addLine(to: CGPoint(x: 0, y: categoryGeo.size.height))
                            categoryPath.addLine(to: CGPoint(x: categoryGeo.size.width, y: categoryGeo.size.height))
                            categoryPath.addLine(to: CGPoint(x: categoryGeo.size.width, y: 0))
                        }
                        .fill(ThreadCategoryColor[self.rootPostCategory]!)
                    }
                    .frame(width: self.categoryWidth)
                    Spacer()
                }
                
                // Collapse Button
                HStack {
                    Spacer()
                    if self.swipeScale > 0.0 {
                        Image(systemName: "eye.slash")
                            .scaleEffect(swipeScale)
                            .padding(.top, 26)
                    }
                    Spacer().frame(width: 20)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    self.showingCollapseAlert = true
                }
                
                // Collapse Alert
                Spacer().frame(width: 0, height: 0)
                .alert(isPresented: self.$showingCollapseAlert) {
                    Alert(title: Text("Hide thread?"), message: Text(""), primaryButton: .default(Text("Yes")) {
                        self.collapseThread = true
                        //self.appSessionStore.collapsedThreads.append(post.id)
                    }, secondaryButton: .cancel() {
                        self.swipeOffset = .zero
                    })
                }
                
                // Author, Contribution, Lols, Replies, Time, Preview
                HStack {
                    VStack {
                        HStack (alignment: .center) {
                            AuthorNameView(name: self.rootPostAuthor, postId: self.threadId)

                            ContributedView(contributed: self.contributed)

                            Spacer()

                            LolView(lols: self.rootPostLols, expanded: true)

                            ReplyCountView(replyCount: self.replyCount)
                            
                            TimeRemainingIndicator(percent:  .constant(self.rootPostDate.getTimeRemaining()))
                                    .frame(width: 10, height: 10)
                        }
                        
                        // Post Preview
                        ZStack {
                            HStack (alignment: .top) {
                                Text(rootPostBodyPreview)
                                    .font(.callout)
                                    .foregroundColor(Color(UIColor.label))
                                    .lineLimit(appSessionStore.abbreviateThreads ? 3 : 8)
                                    .frame(minHeight: 30)
                                    .padding(10)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.callout)
                                    .foregroundColor(Color(UIColor.systemGray))
                                    .padding(.trailing, 20)
                                        .padding(.top, 17)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(RoundedCornersView(color: (self.activeThreadId == self.threadId ? Color("ChatBubbleSecondary") : Color("ChatBubblePrimary"))))
                        .padding(.bottom, 5)
                    }
                    .onAppear(perform: getThreadData)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                }
                .offset(self.swipeOffset)
            }
            .frame(minHeight: 70)
            .border(Color.clear)
            .gesture(DragGesture()
                .onChanged { gesture in
                    self.isSwiping = true
                    self.swipeOffset.width = gesture.translation.width
                }
                .onEnded { _ in
                    if self.swipeOffset.width < -50 {
                        self.swipeScale = 1
                        self.swipeOffset.width = -60
                        self.categoryWidth = 0
                    } else {
                        self.swipeScale = 0.0
                        self.swipeOffset = .zero
                        self.categoryWidth = 3
                    }
                    self.isSwiping = false
                }
            )
        } else {
            EmptyView()
        }
    }
}

struct ThreadRow_Previews: PreviewProvider {
    static var previews: some View {
        ThreadRow(threadId: .constant(999999992), activeThreadId: .constant(999999992))
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
