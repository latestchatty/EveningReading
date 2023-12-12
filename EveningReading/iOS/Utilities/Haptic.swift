//
//  Haptic.swift
//  iOS
//
//  Created by Chris Hodge on 7/24/20.
//

import SwiftUI

class Haptic {
    static func haptic(type: UINotificationFeedbackGenerator.FeedbackType) {
        // error
        // success
        // warning
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        // heavy
        // light
        // medium
        // rigid
        // soft
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
