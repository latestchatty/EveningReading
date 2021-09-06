//
//  FontExtensions.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 8/20/21.
//

import Foundation
import SwiftUI

// https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography#dynamic-type-sizes

// https://gist.github.com/zacwest/916d31da5d03405809c4

// https://stackoverflow.com/questions/58375481/how-to-set-a-custom-font-family-as-the-default-for-an-entire-app-in-swiftui

//TODO: Make changes apply immediately instead of waiting for repaint.
public class FontSettings {
    public static var instance: FontSettings = FontSettings()
           
    private var _fontOffset: CGFloat
    
    public var fontOffset: CGFloat {
        get { return _fontOffset }
        set {
            let def = UserDefaults.standard
            let sanitized = max(min(newValue, 12), -4)
            def.set(sanitized, forKey: "FontSizeOffset")
            _fontOffset = sanitized
        }
    }
    
    private init () {
        self._fontOffset = CGFloat(UserDefaults.standard.float(forKey: "FontSizeOffset"))
    }
}

extension Font {
    
    /// Create a font with the large title text style.
    public static var largeTitle: Font {
        
        return Font.custom("SF Pro", size: 32.0 + FontSettings.instance.fontOffset, relativeTo: .largeTitle)
    }

    /// Create a font with the title text style.
    public static var title: Font {
        return Font.custom("SF Pro", size: 26.0 + FontSettings.instance.fontOffset, relativeTo: .title)
    }
    
    /// Create a font with the title text style.
    public static var title2: Font {
        return Font.custom("SF Pro", size: 20.0 + FontSettings.instance.fontOffset, relativeTo: .title2)
    }
    
    /// Create a font with the title text style.
    public static var title3: Font {
        return Font.custom("SF Pro", size: 18.0 + FontSettings.instance.fontOffset, relativeTo: .title3)
    }

    /// Create a font with the headline text style.
    public static var headline: Font {
        return Font.custom("SF Pro", size: 15.0 + FontSettings.instance.fontOffset, relativeTo: .headline)
    }

    /// Create a font with the subheadline text style.
    public static var subheadline: Font {
        return Font.custom("SF Pro", size: 13.0 + FontSettings.instance.fontOffset, relativeTo: .subheadline)
    }

    /// Create a font with the body text style.
    public static var body: Font {
        return Font.custom("SF Pro", size: 15.0 + FontSettings.instance.fontOffset, relativeTo: .body)
       }

    /// Create a font with the callout text style.
    public static var callout: Font {
        return Font.custom("SF Pro", size: 14.0 + FontSettings.instance.fontOffset, relativeTo: .callout)
       }

    /// Create a font with the footnote text style.
    public static var footnote: Font {
        return Font.custom("SF Pro", size: 12.0 + FontSettings.instance.fontOffset, relativeTo: .footnote)
       }

    /// Create a font with the caption text style.
    public static var caption: Font {
        return Font.custom("SF Pro", size: 11.0 + FontSettings.instance.fontOffset, relativeTo: .caption)
       }

    /// Create a font with the caption2 text style.
    public static var caption2: Font {
        return Font.custom("SF Pro", size: 11.0 + FontSettings.instance.fontOffset, relativeTo: .caption2)
       }
    
    public static func system(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        var font = "SF Pro"
        switch weight {
        case .bold: font = "SF Pro-Bold"
        case .heavy: font = "SF Pro-Bold"
        case .light: font = "SF Pro-Light"
        case .medium: font = "SF Pro"
        case .semibold: font = "SF Pro-Bold"
        case .thin: font = "SF Pro-Light"
        case .ultraLight: font = "SF Pro-Light"
        default: break
        }
        return Font.custom(font, size: size)
    }
}
