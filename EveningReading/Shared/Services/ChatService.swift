//
//  ChatService.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
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

struct ChatLols: Hashable, Codable {
    var tag: String
    var count: Int
}
