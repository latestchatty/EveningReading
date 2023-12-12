//
//  PostTagHelper.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 12/12/23.
//

import Foundation

final class PostTagHelper {
    let postTagCode: [String: String] = [
        "1": "lol",
        "2": "wtf",
        "4": "inf",
        "3": "unf",
        "5": "tag",
        "6": "wow",
        "7": "aww"
    ]
}

enum PostTags: String, CaseIterable {
    case aww = "aww"
    case inf = "inf"
    case lol = "lol"
    case tag = "tag"
    case unf = "unf"
    case wow = "wow"
    case wtf = "wtf"
}

enum PostTag: String, CaseIterable {
    case lol = "lol"
    case inf = "inf"
    case unf = "unf"
    case tag = "tag"
    case wtf = "wtf"
    case wow = "wow"
    case aww = "aww"
}

enum PostTagKey: Int, CaseIterable {
    case lol = 1
    case wtf = 2
    case unf = 3
    case inf = 4
    case tag = 5
    case wow = 6
    case aww = 7
}
