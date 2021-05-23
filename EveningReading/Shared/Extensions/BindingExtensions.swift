//
//  BindingExtensions.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/23/21.
//

import Foundation
import SwiftUI

extension Binding {
    func unwrap<Wrapped>() -> Binding<Wrapped>? where Optional<Wrapped> == Value {
        guard let value = self.wrappedValue else { return nil }
        return Binding<Wrapped>(
            get: {
                return value
            },
            set: { value in
                self.wrappedValue = value
            }
        )
    }
}
