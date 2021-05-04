//
//  watchOsThreadDetail.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct watchOsThreadDetail: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    @Binding var threadId: Int
    
    @State private var rootPostCategory: String = "ontopic"
    @State private var rootPostAuthor: String = ""
    @State private var contributed: Bool = false
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
        ScrollView {
            VStack (alignment: .leading) {
                HStack {
                    AuthorNameView(name: .constant(self.rootPostAuthor))
                    ContributedView(contributed: .constant(self.contributed))
                    Spacer()
                    LolView(lols: self.$lols)
                }
                .padding(.bottom, 2)
                
                HStack {
                    Text(rootPostBody)
                        .font(.footnote)
                }
                
            }
            .padding()
            .background(Color("ThreadBubblePrimary"))
            .cornerRadius(5)
        }
        .onAppear(perform: getThreadData)
    }
}

struct watchOsThreadDetail_Previews: PreviewProvider {
    static var previews: some View {
        watchOsThreadDetail(threadId: .constant(9999999992))
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
            .environmentObject(AppSessionStore())
            .environmentObject(ChatStore(service: ChatService()))
    }
}
