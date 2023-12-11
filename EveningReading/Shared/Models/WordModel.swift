//
//  WordModel.swift
//  EveningReading
//
//  Created by Chris Hodge on 12/11/23.
//

import Foundation

struct Words: Hashable, Codable {
    var words: [Word]
}

struct Word: Hashable, Codable {
    var word: String
}
