//
//  TagPostButton.swift
//  EveningReading (macOS)
//
//  Created by Willie Zutz on 8/19/21.
//

import Foundation
import SwiftUI

struct macOSTagPostButton: View {
    var postId: Int
    @EnvironmentObject var chatService: ChatService
    
    // Copied straight from iOS implementation. Should probably move all this into the ChatService directly?
    private func tagPost(_ tag: String) {
        let defaults = UserDefaults.standard
        let user = defaults.object(forKey: "Username") as? String ?? ""
        
        var userTagsForPost = [String: Int]()
        for tag in PostTag.allCases {
            userTagsForPost[tag.rawValue] = 0
        }
        
        // Find out if we are tagging or untagging then proceed
        chatService.getRaters(postId: postId, completionSuccess: {
                // Check if user already tagged
                for rater in chatService.raters {
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
                    chatService.tag(postId: self.postId, tag: tag, untag: "0")
                    chatService.taggingNoticeText = "Tagged!"
                } else {
                    chatService.tag(postId: self.postId, tag: tag, untag: "1")
                    chatService.taggingNoticeText = "Untagged!"
                }
                
                // Show notice
                //DispatchQueue.main.async {
                // Is asyncAfter necessary to work 100%?
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                    chatService.didTagPost = true
                    chatService.showingTagNotice = true
                }
            }, completionFail: {
                if !(userTagsForPost[tag] ?? 0 > 0) {
                    chatService.tag(postId: self.postId, tag: tag, untag: "0")
                    chatService.taggingNoticeText = "Tagged!"
                } else {
                    chatService.tag(postId: self.postId, tag: tag, untag: "1")
                    chatService.taggingNoticeText = "Untagged!"
                }
                DispatchQueue.main.async {
                    chatService.didTagPost = true
                    chatService.showingTagNotice = true
                }
            }
        )
    }
    
    var body: some View {
        Menu {
            ForEach(Array(PostTag.allCases.enumerated()), id: \.offset) { option in
                Button(option.element.rawValue, action: { self.tagPost(option.element.rawValue) })
            }
        } label: {
            Image(systemName: "tag")
                .imageScale(.large)
        }
        .menuStyle(BorderlessButtonMenuStyle(showsMenuIndicator: false))
        .fixedSize()
        .help("Tag post")
    }
}
