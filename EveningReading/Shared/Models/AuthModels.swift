//
//  AuthModels.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 12/6/23.
//

import Foundation

struct AuthResponse: Hashable, Codable {
    var isValid: Bool
    var isModerator: Bool
}
