//
//  ArticleModels.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 12/6/23.
//

import Foundation

struct ArticleWrapper: Decodable {
    let articles: [Article]
}

struct Article: Hashable, Codable {
    var body: String
    var date: String
    var id: Int
    var name: String
    var preview: String
    var url: String
}

struct ArticleDetails: Hashable, Codable {
    var preview: String
    var name: String
    var body: Int
    var date: String
    var comment_count: Int
    var id: Int
    var thread_id: Int
}
