//
//  Colors.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 12/12/23.
//

import Foundation
import SwiftUI

#if os(iOS)
let ThreadCategoryColor: [String: Color] = [
    "informative": Color(UIColor.systemBlue),
    "tangent": Color(UIColor.systemGray),
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
    "wtf": Color(UIColor.systemPurple),
    "wow": Color(UIColor.systemGray),
    "aww": Color(UIColor.systemTeal)
]
#endif

#if os(OSX)
let ThreadCategoryColor: [String: Color] = [
    "informative": Color(NSColor.systemBlue),
    "tangent": Color(NSColor.systemGray),
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
    "wtf": Color(NSColor.systemPurple),
    "wow": Color(NSColor.systemGray),
    "aww": Color(NSColor.systemTeal)
]
#endif

#if os(watchOS)
let ThreadCategoryColor: [String: Color] = [
    "informative": Color.blue,
    "tangent": Color.gray,
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
#endif
