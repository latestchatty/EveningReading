//
//  TagPostView.swift
//  iOS
//
//  Created by Chris Hodge on 7/15/20.
//

import SwiftUI

struct TagPostView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    var postId: Int
    
    @State private var showingTagActionSheet = false
    @State private var tag = ""
    
    // Tag or untag a post
    private func tagPost(_ tag: String) {
        let user: String? = KeychainWrapper.standard.string(forKey: "Username")
        
        var userTagsForPost = [String: Int]()
        for tag in PostTag.allCases {
            userTagsForPost[tag.rawValue] = 0
        }
        
        // Find out if we are tagging or untagging then proceed
        chatStore.getRaters(postId: postId, completionSuccess: {
                // Check if user already tagged
                for rater in chatStore.raters {
                    for username in rater.usernames {
                        if username == user {
                            if let userTagged = PostTagCode[rater.tag] {
                                userTagsForPost[userTagged] = 1
                            }
                        }
                    }
                }
            
                // Tag or untag
                if (userTagsForPost[tag] ?? 0 < 1) {
                    chatStore.tag(postId: self.postId, tag: tag, untag: "0")
                    chatStore.taggingNoticeText = "Tagged!"
                } else {
                    chatStore.tag(postId: self.postId, tag: tag, untag: "1")
                    chatStore.taggingNoticeText = "Untagged!"
                }
                
                // Show notice
                DispatchQueue.main.async {
                    chatStore.didTagPost = true
                }
            }, completionFail: {
                if !(userTagsForPost[tag] ?? 0 > 0) {
                    chatStore.tag(postId: self.postId, tag: tag, untag: "0")
                } else {
                    chatStore.tag(postId: self.postId, tag: tag, untag: "1")
                }
            }
        )
    }
    
    // Make tag action sheet
    private func getTacActionSheet() -> ActionSheet {
        let buttons = PostTag.allCases.enumerated().map { i, option in
            Alert.Button.default(Text(option.rawValue), action: { self.tagPost(option.rawValue) } )
        }
        return ActionSheet(title: Text("Tags"),
                       buttons: buttons + [Alert.Button.cancel()])
    }

    var body: some View {
        VStack {
            Button(action: {
                chatStore.didTagPost = false
                self.showingTagActionSheet = true
            }) {
                ZStack{
                    Image(systemName: "circle.fill")
                        .font(.title)
                        .foregroundColor(Color("ActionButton"))
                        .shadow(color: Color("ActionButtonShadow"), radius: 4, x: 0, y: 0)
                    Image(systemName: "tag")
                        .imageScale(.medium)
                        .foregroundColor(self.colorScheme == .dark ? Color(UIColor.white) : Color(UIColor.systemBlue))
                }
            }
            .actionSheet(isPresented: self.$showingTagActionSheet)
            {
                getTacActionSheet()
            }
        }
    }
}

struct TagPostView_Previews: PreviewProvider {
    static var previews: some View {
        TagPostView(postId: 0)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
