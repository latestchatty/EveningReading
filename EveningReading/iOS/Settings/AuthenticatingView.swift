//
//  AuthenticatingView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/7/21.
//

import SwiftUI

struct AuthenticatingView : View {
    @Binding var isVisible: Bool

    init(isVisible: Binding<Bool>) {
        self._isVisible = isVisible
    }
    
    var body: some View {
        ZStack {
            VStack {
                ProgressView()
            }
            .frame(width: 120,
                   height: 120)
            .background(BlurView(style: .systemUltraThinMaterial))
            .foregroundColor(Color.primary)
            .cornerRadius(20)
            .opacity(self.isVisible ? 1 : 0)
            
            Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
