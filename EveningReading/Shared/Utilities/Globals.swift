//
//  Globals.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import Foundation
import SwiftUI

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
#else
let ThreadCategoryColor: [String: Color] = [
    "informative": Color(UIColor.systemBlue),
    "offtopic": Color(UIColor.systemGray),
    "stupid": Color(UIColor.systemGreen),
    "political": Color(UIColor.systemOrange),
    "nws": Color(UIColor.systemRed),
    "ontopic": Color(UIColor.clear),
    "": Color(UIColor.clear)
]
#endif

