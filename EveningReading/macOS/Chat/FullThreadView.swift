//
//  FullThreadView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct FullThreadView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    @Binding var threadId: Int
    
    @State private var rootPostCategory: String = "ontopic"
    @State private var rootPostAuthor: String = ""
    @State private var contributed: Bool = false
    @State private var replyCount: Int = 0
    @State private var rootPostBody: String = ""
    @State private var rootPostDate: String = "2020-08-14T21:05:00Z"
    @State private var hasLols: Bool = false
    @State private var lols = [String: Int]()
    @State private var lolTypeCount: Int = 0
    
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

    var body: some View {
        VStack (alignment: .leading) {
            
            ThreadCategoryColor[self.rootPostCategory].frame(height: 5)
            
            HStack {
                AuthorNameView(name: self.$rootPostAuthor)
                
                ContributedView(contributed: self.$contributed)
                
                if self.hasLols {
                    LolView(lols: self.$lols)
                }
                Spacer()
                
                TimeRemainingIndicator(percent: .constant(self.rootPostDate.getTimeRemaining()))
                    .frame(width: 10, height: 10)
                
                Text(self.rootPostDate.getTimeAgo())
                    .font(.body)
                
                Image(systemName: "eye.slash")
                    .imageScale(.large)
                    .onTapGesture(count: 1) {
                    }
                
                Image(systemName: "tag")
                    .imageScale(.large)
                    .onTapGesture(count: 1) {
                    }
                
                Image(systemName: "arrowshape.turn.up.left")
                    .imageScale(.large)
                    .onTapGesture(count: 1) {
                    }
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
            HStack {
                Text("\(self.rootPostBody)")
                    .font(.body)
            }
            .padding(.init(top: 0, leading: 20, bottom: 15, trailing: 20))

        }
        .onAppear(perform: getThreadData)
        .frame(maxWidth: .infinity)
        .background(Color("ThreadBubblePrimary"))
        .cornerRadius(10)
        .padding(.init(top: 0, leading: 20, bottom: 10, trailing: 20))
    }
}

struct FullThreadView_Previews: PreviewProvider {
    static var previews: some View {
        FullThreadView(threadId: .constant(9999999992))
            .environmentObject(AppSessionStore())
            .environmentObject(ChatStore(service: ChatService()))
    }
}
