//
//  PostDecorator.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/7/21.
//

import Foundation
import SwiftUI

class PostDecorator {
    // Post weights depend on the age of the post
    let postWeight: [Double: Font.Weight] = [
        0.95: .heavy,
        0.90: .bold,
        0.85: .semibold,
        0.80: .medium,
        0.75: .regular
    ]
    
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

        let contributedReplies = thread.posts.filter({ return $0.author.lowercased() == username }).count
        
        if username == author.lowercased() || contributedReplies > 0 {
            return true
        } else {
            return false
        }
    }
}
