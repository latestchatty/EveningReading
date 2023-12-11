//
//  LoadingView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/8/21.
//

import SwiftUI

struct LoadingView : View {
    @Binding public var show: Bool
    @Binding public var title: String
    
    private func getBlurForOS() -> BlurView {
        #if os(iOS)
        return BlurView(style: .systemUltraThinMaterial)
        #elseif os(macOS)
        return BlurView()
        #endif
    }
    
    var body: some View {
        if show {
            if title != "" {
                ProgressView(title)
                    .frame(width: 120,
                           height: 120)
                    .background(getBlurForOS())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
            } else {
                ProgressView()
                    .frame(width: 120,
                           height: 120)
                    .background(getBlurForOS())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
            }
        } else {
            EmptyView()
        }
    }
}
