//
//  ColorExtensions.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/9/21.
//

import Foundation
import SwiftUI

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red: red, green: green, blue: blue, alpha: alpha)
    }

    var red: CGFloat {
        return self.rgba.red
    }

    var blue: CGFloat {
        return self.rgba.blue
    }

    var green: CGFloat {
        return self.rgba.green
    }

    var alpha: CGFloat {
        return self.rgba.alpha
    }

    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r*255) << 24 | (Int)(g*255) << 16 | (Int)(b*255) << 8 | (Int)(a*255) << 0

        let string = String(format:"#%08x", rgb)
        return string
    }

    func toRGBAString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        return "rgba(\(r*255), \(g*255), \(b*255), \(a))"
    }
}
