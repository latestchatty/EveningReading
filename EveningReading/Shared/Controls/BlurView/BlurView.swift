//
//  BlurView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/7/21.
//

import SwiftUI

#if os(iOS)
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
#elseif os(macOS)
struct BlurView: NSViewRepresentable
{
    func makeNSView(context: Context) -> NSVisualEffectView
    {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = .popover
        visualEffectView.blendingMode = .withinWindow
        visualEffectView.state = .followsWindowActiveState
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context)
    {
        visualEffectView.material = .popover
        visualEffectView.blendingMode = .withinWindow
    }
}
#endif
