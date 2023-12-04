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

extension Font {
    
    /// Create a font with the large title text style.
    public static var largeTitle: Font {
        return Font.custom("HelveticaNeue", size: 33.0, relativeTo: .largeTitle)
    }

    /// Create a font with the title text style.
    public static var title: Font {
        return Font.custom("HelveticaNeue", size: 27.0, relativeTo: .title)
    }
    
    /// Create a font with the title text style.
    public static var title2: Font {
        return Font.custom("HelveticaNeue", size: 21.0, relativeTo: .title2)
    }
    
    /// Create a font with the title text style.
    public static var title3: Font {
        return Font.custom("HelveticaNeue", size: 19.0, relativeTo: .title3)
    }

    /// Create a font with the headline text style.
    public static var headline: Font {
        return Font.custom("HelveticaNeue", size: 16.0, relativeTo: .headline)
    }

    /// Create a font with the subheadline text style.
    public static var subheadline: Font {
        return Font.custom("HelveticaNeue", size: 14.0, relativeTo: .subheadline)
    }

    /// Create a font with the body text style.
    public static var body: Font {
        return Font.custom("HelveticaNeue", size: 16.0, relativeTo: .body)
       }

    /// Create a font with the callout text style.
    public static var callout: Font {
        return Font.custom("HelveticaNeue", size: 15.0, relativeTo: .callout)
       }

    /// Create a font with the footnote text style.
    public static var footnote: Font {
        return Font.custom("HelveticaNeue", size: 12.0, relativeTo: .footnote)
       }

    /// Create a font with the caption text style.
    public static var caption: Font {
        return Font.custom("HelveticaNeue", size: 11.0, relativeTo: .caption)
       }

    /// Create a font with the caption2 text style.
    public static var caption2: Font {
        return Font.custom("HelveticaNeue", size: 11.0, relativeTo: .caption2)
       }
    
    public static func system(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        var font = "HelveticaNeue"
        switch weight {
        case .bold: font = "HelveticaNeue-Bold"
        case .heavy: font = "HelveticaNeue-Bold"
        case .light: font = "HelveticaNeue-Light"
        case .medium: font = "HelveticaNeue"
        case .semibold: font = "HelveticaNeue-Bold"
        case .thin: font = "HelveticaNeue-Light"
        case .ultraLight: font = "HelveticaNeue-Light"
        default: break
        }
        return Font.custom(font, size: size)
    }
}
