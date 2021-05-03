//
//  ChatRow.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct ChatRow: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore

    @Binding var threadId: Int

    @State private var categoryWidth : CGFloat = 3
    @State private var rootPostCategory = "ontopic"
    @State private var rootPostAuthor = ""
    @State private var hasContributed: Bool = false
    @State private var replyCount: Int = 0
    @State private var rootPostBody: String = ""
    @State private var postDate: String = "2020-08-14T21:05:00Z"
    @State private var hasLols: Bool = false

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
            }
        }
        if let thread = chatData.threads.filter({ return $0.threadId == self.threadId }).first {
            let rootPost = thread.posts.filter({ return $0.parentId == 0 }).first
            self.rootPostCategory = rootPost?.category ?? "ontopic"
            self.rootPostAuthor = rootPost?.author ?? ""
            self.rootPostBody = rootPost?.body.getPreview ?? ""
        }
    }
    
    private func isAuthor() -> Bool {
        return false
    }
    
    var body: some View {
        ZStack {
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
                //self.showingHideAlert = true
            }
            
            /*
            Spacer().frame(width: 0, height: 0)
            .alert(isPresented: self.$showingHideAlert) {
                Alert(title: Text("Hide thread?"), message: Text(""), primaryButton: .default(Text("Yes")) {
                    self.showRow = false
                    self.appSessionStore.collapsedThreads.append(post.id)
                }, secondaryButton: .cancel() {
                    self.swipeOffset = .zero
                })
            }
            */
            
            HStack {
                VStack {
                    HStack (alignment: .center) {
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
                        
                        if self.hasContributed {
                            Image(systemName: "pencil")
                                .imageScale(.small)
                                .foregroundColor(Color(UIColor.systemTeal))
                                .padding(.leading, 5)
                                .offset(x: 0, y: -1)
                        }
                        Spacer()

                        HStack {
                            Text(" ")
                                .font(.caption2)
                                .fontWeight(.bold)
                            /*
                            ForEach(tagCounts.sorted(by: <), id: \.key) { key, value in
                                if value + (self.chattyStore.tagDelta[self.post.id]?[key] ?? 0) > 0 && !truncateTag(postId: self.post.id, tagType: key) {
                                    HStack {
                                        Text(key)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(PostTagColor[key])
                                        +
                                        Text(" \(value + (self.chattyStore.tagDelta[self.post.id]?[key] ?? 0))")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(PostTagColor[key])
                                    }
                                }
                            }
                            */
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

                        Text("\(self.replyCount)")
                            .font(.footnote)
                            .foregroundColor(Color(UIColor.systemGray)) +
                        Text(self.replyCount == 1 ? " Reply" : " Replies")
                                .font(.footnote)
                                .foregroundColor(Color(UIColor.systemGray))
                                                 
                        TimeRemainingIndicator(percent:  .constant(self.postDate.getTimeRemaining()))
                                .frame(width: 10, height: 10)
                    }
                    
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
    }
}

struct ChatRow_Previews: PreviewProvider {
    static var previews: some View {
        ChatRow(threadId: .constant(9999999992))
            .environmentObject(AppSessionStore())
            .environmentObject(ChatStore(service: ChatService()))
    }
}
