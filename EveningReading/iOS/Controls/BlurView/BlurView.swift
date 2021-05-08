//
//  BlurView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/7/21.
//

import SwiftUI

struct BlurView: UIViewRepresentable {
    //.systemUltraThinMaterial
    //.systemThinMaterial
    //.systemMaterial (default)
    //.systemThickMaterial
    //.systemChromeMaterial
    
    var style: UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
