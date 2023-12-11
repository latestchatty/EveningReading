//
//  MessageModels.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 12/6/23.
//

import Foundation

struct MessageWrapper: Hashable, Codable {
    var messages: MessageResponse
}

struct MessageResponse: Hashable, Codable {
    var page: Int
    var totalPages: Int
    var totalMessages: Int
    var messages: [Message]
}

struct Message: Hashable, Codable {
    var id: Int
    var from: String
    var to: String
    var subject: String
    var date: String
    var body: String
    var unread: Bool
}

struct MessageCount: Hashable, Codable {
    var total: Int
    var unread: Int
}

struct SubmitMessageResponseContainer: Hashable, Codable {
    var success: SubmitMessageResponse
    var fail: SubmitMessageError
}

struct SubmitMessageResponse: Hashable, Codable {
    var result: String
}

struct SubmitMessageError: Hashable, Codable {
    var error: Bool
    var code: String
    var message : String
}

struct MarkMessageContainer: Hashable, Codable {
    var success: MarkMessageResponse
    var fail: MarkMessageError
}

struct MarkMessageResponse: Hashable, Codable {
    var result: String
}

struct MarkMessageError: Hashable, Codable {
    var type: String
    var title: String
    var status: Int
    var traceId: String
    var errors: MarkMessageErrors
}

struct MarkMessageErrors: Hashable, Codable {
    var MessageId: [String]
}
