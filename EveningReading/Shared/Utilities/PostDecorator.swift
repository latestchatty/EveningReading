//
//  PostDecorator.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/7/21.
//

import Foundation

class PostDecorator {
    
    // Make font weight/opacity based on how recent
    static func getPostStrength(thread: ChatThread) -> [Int: Double] {
        let recent = Array(thread.posts.sorted(by: { $0.id > $1.id }).prefix(5))
        var opacity = 0.95
        var strength = [Int: Double]()
        for recentPost in recent {
            strength[recentPost.id] = opacity
            opacity = round(1000.0 * (opacity - 0.05)) / 1000.0
        }
        return strength
    }
    
    // Check if participated in thread
    static func checkParticipatedStatus(thread: ChatThread, author: String) -> Bool {
        #if os(iOS)
        let username: String? = KeychainWrapper.standard.string(forKey: "Username")?.lowercased()
        #endif
        
        #if os(macOS)
        var username = UserDefaults.standard.object(forKey: "Username") as? String ?? ""
        username = username.lowercased()
        #endif
        
        #if os(watchOS)
        let username = ""
        #endif
        
        // If we're the thread root author, we've participated. Bail out now.
        if username == author.lowercased() {
            return true
        }
        
        // Use for loop instead of filter so we short circuit and bail out as soon as we find what we're looking for.
        for post in thread.posts {
            if post.author.lowercased() == username {
                return true
            }
        }
        return false
    }
    
    // Check if there are unread replies to the user in the thread
    static func checkUnreadReplies(thread: ChatThread, viewedPostsStore: ViewedPostsStore) -> Bool {
        #if os(iOS)
        let username: String? = KeychainWrapper.standard.string(forKey: "Username")?.lowercased()
        #endif
        
        #if os(macOS)
        var username = UserDefaults.standard.object(forKey: "Username") as? String ?? ""
        username = username.lowercased()
        #endif
        
        #if os(watchOS)
        let username = ""
        #endif
        
        // Get all the posts the user has made in the thread
        let authorPostIds = thread.posts.filter({$0.author.lowercased() == username}).map({$0.id})
        
        // Then find out if anything that's a direct reply is unread
        for p in thread.posts {
            if authorPostIds.contains(p.parentId) {
                if !viewedPostsStore.isPostViewed(postId: p.id){
                    return true
                }
            }
        }
        return false
    }
}
