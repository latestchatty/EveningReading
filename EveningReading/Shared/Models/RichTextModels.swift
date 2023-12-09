//
//  RichTextModels.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 12/9/23.
//

import Foundation

struct InlineText: Hashable {
    var text: String
    let attributes: TextAttributes
}

struct SpoilerBlock: Hashable {
    var text: String
}

struct LinkBlock: Hashable {
    var hyperlink: String
    var description: String
}

struct SpoilerLinkBlock: Hashable {
    var hyperlink: String
    var description: String
}

enum ShackMarkupType: Hashable {
    case tag, content
}

struct ShackPostMarkup: Hashable {
    let postMarkup: String
    let postMarkupType: ShackMarkupType
}
