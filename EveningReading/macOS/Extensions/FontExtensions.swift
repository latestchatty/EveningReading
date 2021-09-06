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
    public static func getFontOffset() -> CGFloat {
        let def = UserDefaults.standard
        return CGFloat(def.float(forKey: "FontSizeOffset"))
    }
    
    public static func setFontOffset(_ offset: CGFloat) {
        let def = UserDefaults.standard
        def.set(max(min(offset, 12), -4), forKey: "FontSizeOffset")
    }
}

extension Font {
    
    /// Create a font with the large title text style.
    public static var largeTitle: Font {
        
        return Font.custom("SF Pro", size: 32.0 + FontSettings.getFontOffset(), relativeTo: .largeTitle)
    }

    /// Create a font with the title text style.
    public static var title: Font {
        return Font.custom("SF Pro", size: 26.0 + FontSettings.getFontOffset(), relativeTo: .title)
    }
    
    /// Create a font with the title text style.
    public static var title2: Font {
        return Font.custom("SF Pro", size: 20.0 + FontSettings.getFontOffset(), relativeTo: .title2)
    }
    
    /// Create a font with the title text style.
    public static var title3: Font {
        return Font.custom("SF Pro", size: 18.0 + FontSettings.getFontOffset(), relativeTo: .title3)
    }

    /// Create a font with the headline text style.
    public static var headline: Font {
        return Font.custom("SF Pro", size: 15.0 + FontSettings.getFontOffset(), relativeTo: .headline)
    }

    /// Create a font with the subheadline text style.
    public static var subheadline: Font {
        return Font.custom("SF Pro", size: 13.0 + FontSettings.getFontOffset(), relativeTo: .subheadline)
    }

    /// Create a font with the body text style.
    public static var body: Font {
        return Font.custom("SF Pro", size: 15.0 + FontSettings.getFontOffset(), relativeTo: .body)
       }

    /// Create a font with the callout text style.
    public static var callout: Font {
        return Font.custom("SF Pro", size: 14.0 + FontSettings.getFontOffset(), relativeTo: .callout)
       }

    /// Create a font with the footnote text style.
    public static var footnote: Font {
        return Font.custom("SF Pro", size: 12.0 + FontSettings.getFontOffset(), relativeTo: .footnote)
       }

    /// Create a font with the caption text style.
    public static var caption: Font {
        return Font.custom("SF Pro", size: 11.0 + FontSettings.getFontOffset(), relativeTo: .caption)
       }

    /// Create a font with the caption2 text style.
    public static var caption2: Font {
        return Font.custom("SF Pro", size: 11.0 + FontSettings.getFontOffset(), relativeTo: .caption2)
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
