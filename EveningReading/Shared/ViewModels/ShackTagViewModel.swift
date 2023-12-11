//
//  ShackTagViewModel.swift
//  EveningReading
//
//  Created by Chris Hodge on 12/11/23.
//

import SwiftUI

class ShackTagViewModel: ObservableObject {
    @Published var tagColors: [ShackTagColor] = [
        ShackTagColor(label: "Red", tag: "r{}r", color: Color(UIColor.systemRed)),
        ShackTagColor(label: "Green", tag: "g{}g", color: Color(UIColor.systemGreen)),
        ShackTagColor(label: "Blue", tag: "b{}b", color: Color(UIColor.systemBlue)),
        ShackTagColor(label: "Yellow", tag: "y{}y", color: Color("YellowText")),
        ShackTagColor(label: "Lime", tag: "l[]l", color: Color("LimeText")),
        ShackTagColor(label: "Orange", tag: "n[]n", color: Color(UIColor.systemOrange)),
        ShackTagColor(label: "Pink", tag: "p[]p", color: Color("PinkText")),
        ShackTagColor(label: "Olive", tag: "e[]e", color: Color("OliveText"))
    ]
    
    @Published var tagFormats: [ShackTagFormat] = [
        ShackTagFormat(label: "Italic", tag: "/[]/"),
        ShackTagFormat(label: "Bold", tag: "b[]b"),
        ShackTagFormat(label: "Under", tag: "_[]_"),
        ShackTagFormat(label: "Quote", tag: "q[]q"),
        ShackTagFormat(label: "Code", tag: "/{{}}/"),
        ShackTagFormat(label: "Sample", tag: "s[]s"),
        ShackTagFormat(label: "Strike", tag: "-[]-"),
        ShackTagFormat(label: "Spoiler", tag: "o[]o"),
        ShackTagFormat(label: "Italic", tag: "/[]/"),
    ]
}
