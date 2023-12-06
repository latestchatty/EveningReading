//
//  PushNotificationModels.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 12/6/23.
//

import Foundation

struct PushNotification : Hashable, Codable {
    var title = ""
    var body = ""
    var postId = 0
}

struct RegisterPushResponse {
    var status: Int
    var message: String
}
