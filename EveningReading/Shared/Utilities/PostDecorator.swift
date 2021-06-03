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
        let username: String? = KeychainWrapper.standard.string(forKey: "Username")?.lowercased()

        let contributedReplies = thread.posts.filter({ return $0.author.lowercased() == username }).count
        
        if username == author.lowercased() || contributedReplies > 0 {
            return true
        } else {
            return false
        }
    }
}
