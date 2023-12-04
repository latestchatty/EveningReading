//
//  RedactingView.swift
//  iOS
//
//  Created by Chris Hodge on 8/15/20.
//

import SwiftUI

struct RedactingView<Input: View, Output: View>: View {
    var content: Input
    var modifier: (Input) -> Output

    @Environment(\.redactionReasons) private var reasons

    var body: some View {
        if reasons.isEmpty {
            content
        } else {
            modifier(content)
        }
    }
}

extension View {
    func whenRedacted<T: View>(
        apply modifier: @escaping (Self) -> T
    ) -> some View {
        RedactingView(content: self, modifier: modifier)
    }
}

struct RedactedModifier: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .redacted(reason: .placeholder)
    }
}

extension View {
    // If condition is met, apply modifier, otherwise, leave the view untouched
    public func conditionalModifier<T>(_ condition: Bool, _ modifier: T) -> some View where T: ViewModifier {
        Group {
            if condition {
                self.modifier(modifier)
            } else {
                self
            }
        }
    }

    // Apply trueModifier if condition is met, or falseModifier if not.
    public func conditionalModifier<M1, M2>(_ condition: Bool, _ trueModifier: M1, _ falseModifier: M2) -> some View where M1: ViewModifier, M2: ViewModifier {
        Group {
            if condition {
                self.modifier(trueModifier)
            } else {
                self.modifier(falseModifier)
            }
        }
    }
    
    // If condition is met, apply modifier, otherwise, leave the view untouched
    public func conditionalModifier<T>(_ id: Int, _ modifier: T) -> some View where T: ViewModifier {
        Group {
            if (999999991...999999999).contains(id) {
                self.modifier(modifier)
            } else {
                self
            }
        }
    }
}
