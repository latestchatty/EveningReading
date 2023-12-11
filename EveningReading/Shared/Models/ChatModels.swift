//
//  ChatModels.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 12/6/23.
//

import Foundation

struct Chat: Hashable, Codable {
    var threads: [ChatThread]
}

struct ChatThread: Hashable, Codable {
    var threadId: Int
    var posts: [ChatPosts]
}

struct ChatPosts: Hashable, Codable {
    var id: Int
    var threadId: Int
    var parentId: Int
    var author: String
    var category: String
    var date: String
    var body: String
    var lols: [ChatLols]
}

struct ChatLols: Hashable, Codable, Comparable {
    var tag: String
    var count: Int
    
    static func <(lhs: ChatLols, rhs: ChatLols) -> Bool {
        return lhs.tag < rhs.tag
    }
}

// Submission
struct SubmitPostResponseContainer: Hashable, Codable {
    var success: SubmitPostReponse
    var fail: SubmitPostError
}

struct SubmitPostReponse: Hashable, Codable {
    var result: String
}

struct SubmitPostError: Hashable, Codable {
    var error: Bool
    var code: String
    var message : String
}

// Search
struct SearchChat: Hashable, Codable {
    var posts: [SearchChatPosts]
}

struct SearchChatPosts: Hashable, Codable {
    var id: Int
    var threadId: Int
    var parentId: Int
    var author: String
    var authorId: Int
    var category: String
    var date: String
    var body: String
    var lols: [Int]
    var isCortex: Bool
    var isFrozen: Bool
}

// Tagging
struct RatersWrapper: Hashable, Codable {
    var raters: RatersResponse
}

struct RatersResponse: Hashable, Codable {
    var status: String
    var data: [Raters]
    var message: String
}

struct Raters: Hashable, Codable {
    var thread_id: String
    var user_ids: [String]
    var usernames: [String]
    var tag: String
}

struct TagReponse: Hashable, Codable {
    var status: String
    var data: String?
    var message: String
}
