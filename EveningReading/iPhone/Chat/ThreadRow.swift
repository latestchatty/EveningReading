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

    @State private var categoryWidth: CGFloat = 3
    @State private var rootPostCategory: String = "ontopic"
    @State private var rootPostAuthor: String = ""
    @State private var hasContributed: Bool = false
    @State private var replyCount: Int = 0
    @State private var rootPostBody: String = ""
    @State private var postDate: String = "2020-08-14T21:05:00Z"
    @State private var hasLols: Bool = false
    @State private var lols = [String: Int]()
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
                self.rootPostBody = rootPost?.body.getPreview ?? ""
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
            self.rootPostBody = rootPost?.body.getPreview ?? ""
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
    
    private func isAuthor() -> Bool {
        return false
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
                
                // Collapse
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
                
                Spacer().frame(width: 0, height: 0)
                .alert(isPresented: self.$showingCollapseAlert) {
                    Alert(title: Text("Hide thread?"), message: Text(""), primaryButton: .default(Text("Yes")) {
                        self.collapseThread = true
                        //self.appSessionStore.collapsedThreads.append(post.id)
                    }, secondaryButton: .cancel() {
                        self.swipeOffset = .zero
                    })
                }
                
                // Author, Contribution, Tags, Replies, Time
                HStack {
                    VStack {
                        HStack (alignment: .center) {
                            // Author
                            Text("\(self.rootPostAuthor)")
                                .font(.footnote)
                                .bold()
                                .foregroundColor(Color(UIColor.systemOrange))
                                .lineLimit(1)
                                .contextMenu {
                                    Button(action: {
                                        // send message
                                    }) {
                                        Text("Send Message")
                                        Image(systemName: "envelope.circle")
                                    }
                                    Button(action: {
                                        // search posts
                                    }) {
                                        Text("Search Post History")
                                        Image(systemName: "magnifyingglass.circle")
                                    }
                                    Button(action: {
                                        // report user
                                    }) {
                                        Text("Report User")
                                        Image(systemName: "exclamationmark.circle")
                                    }
                                }

                            /*
                            NavigationLink(destination: SearchView(populateTerms: Binding.constant(""), populateAuthor: Binding.constant(post.author), populateParent: Binding.constant("")), isActive: self.$showingSearchView) {
                                Spacer().frame(width: 0, height: 0)
                            }
                            */
                            
                            // Contribution
                            if self.hasContributed {
                                #if os(iOS)
                                    Image(systemName: "pencil")
                                        .imageScale(.small)
                                        .foregroundColor(Color(UIColor.systemTeal))
                                        .padding(.leading, 5)
                                        .offset(x: 0, y: -1)
                                #else
                                    Image(systemName: "pencil")
                                        .imageScale(.small)
                                        .foregroundColor(Color(NSColor.systemTeal))
                                        .padding(.leading, 5)
                                        .offset(x: 0, y: -1)
                                #endif
                            }
                            Spacer()

                            // Lols
                            HStack {
                                Text(" ")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                ForEach(self.lols.sorted(by: <), id: \.key) { key, value in
                                    if value > 0 {
                                        HStack {
                                            Text(key)
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(PostTagColor[key])
                                            +
                                            Text(" \(value)")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(PostTagColor[key])
                                        }
                                    }
                                }
                            }
                            .contextMenu {
                                if self.hasLols {
                                    Button(action: {
                                        // show who's tagging
                                    }) {
                                        Text("Who's Tagging?")
                                        Image(systemName: "tag.circle")
                                    }
                                }
                            }

                            // Reply Count
                            Text("\(self.replyCount)")
                                .font(.footnote)
                                .foregroundColor(Color(UIColor.systemGray)) +
                            Text(self.replyCount == 1 ? " Reply" : " Replies")
                                    .font(.footnote)
                                    .foregroundColor(Color(UIColor.systemGray))
                                                     
                            TimeRemainingIndicator(percent:  .constant(self.postDate.getTimeRemaining()))
                                    .frame(width: 10, height: 10)
                        }
                        
                        // Post Preview
                        ZStack {
                            HStack (alignment: .top) {
                                Text(rootPostBody)
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
                        .background(RoundedCornersView(color: (isAuthor() ? Color("ChatBubbleAuthor") : Color("ChatBubblePrimary")), shadowColor: Color("ChatBubbleShadow"), tl: 0, tr: 10, bl: 10, br: 10))
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
        ThreadRow(threadId: .constant(9999999992))
            .environmentObject(AppSessionStore())
            .environmentObject(ChatStore(service: ChatService()))
    }
}
