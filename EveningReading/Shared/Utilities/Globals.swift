//
//  ShackGlobals.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import Foundation
import SwiftUI

#if os(iOS)
let ThreadCategoryColor: [String: Color] = [
    "informative": Color(UIColor.systemBlue),
    "offtopic": Color(UIColor.systemGray),
    "stupid": Color(UIColor.systemGreen),
    "political": Color(UIColor.systemOrange),
    "nws": Color(UIColor.systemRed),
    "ontopic": Color(UIColor.clear),
    "": Color(UIColor.clear)
]
let PostTagColor: [String: Color] = [
    "lol": Color(UIColor.systemYellow),
    "inf": Color(UIColor.systemBlue),
    "unf": Color(UIColor.systemRed),
    "tag": Color(UIColor.systemGreen),
    "wtf": Color(UIColor.systemPink),
    "wow": Color(UIColor.systemGray),
    "aww": Color(UIColor.systemTeal)
]
let AuthorColor: [AuthorType: Color] = [
    AuthorType.shacknews: Color(UIColor.systemPurple),
    AuthorType.currentUser: Color(UIColor.systemTeal),
    AuthorType.unknown: Color(UIColor.systemOrange),
    AuthorType.threadOp: Color(UIColor.systemGreen)
]
#endif

#if os(OSX)
let ThreadCategoryColor: [String: Color] = [
    "informative": Color(NSColor.systemBlue),
    "offtopic": Color(NSColor.systemGray),
    "stupid": Color(NSColor.systemGreen),
    "political": Color(NSColor.systemOrange),
    "nws": Color(NSColor.systemRed),
    "ontopic": Color(NSColor.clear),
    "": Color(NSColor.clear)
]
let PostTagColor: [String: Color] = [
    "lol": Color(NSColor.systemYellow),
    "inf": Color(NSColor.systemBlue),
    "unf": Color(NSColor.systemRed),
    "tag": Color(NSColor.systemGreen),
    "wtf": Color(NSColor.systemPink),
    "wow": Color(NSColor.systemGray),
    "aww": Color(NSColor.systemTeal)
]
let AuthorColor: [AuthorType: Color] = [
    AuthorType.shacknews: Color(NSColor.systemPurple),
    AuthorType.currentUser: Color(NSColor.systemTeal),
    AuthorType.unknown: Color(NSColor.systemOrange),
    AuthorType.threadOp: Color(NSColor.systemGreen)
]

#endif

#if os(watchOS)
let ThreadCategoryColor: [String: Color] = [
    "informative": Color.blue,
    "offtopic": Color.gray,
    "stupid": Color.green,
    "political": Color.orange,
    "nws": Color.red,
    "ontopic": Color.clear,
    "": Color.clear
]
let PostTagColor: [String: Color] = [
    "lol": Color.yellow,
    "inf": Color.blue,
    "unf": Color.red,
    "tag": Color.green,
    "wtf": Color.pink,
    "wow": Color.gray,
    "aww": Color.purple
]
let AuthorColor: [AuthorType: Color] = [
    AuthorType.shacknews: Color.purple,
    AuthorType.currentUser: Color.teal,
    AuthorType.unknown: Color.orange,
    AuthorType.threadOp: Color.green
]
#endif

enum AuthorType {
    case currentUser
    case shacknews
    case threadOp
    case unknown
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

let PostTagCode: [String: String] = [
    "1": "lol",
    "2": "wtf",
    "4": "inf",
    "3": "unf",
    "5": "tag",
    "6": "wow",
    "7": "aww"
]

let PostWeight: [Double: Font.Weight] = [
    0.95: .heavy,
    0.90: .bold,
    0.85: .semibold,
    0.80: .medium,
    0.75: .regular
]
