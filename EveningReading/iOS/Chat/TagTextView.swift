//
//  TagTextView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/26/21.
//

import Foundation
import SwiftUI

struct ShackTagColor: Hashable {
    var label: String
    var tag: String
    var color: Color
}

let ShackTagColors = [
    ShackTagColor(label: "Red", tag: "r{}r", color: Color(UIColor.systemRed)),
    ShackTagColor(label: "Green", tag: "g{}g", color: Color(UIColor.systemGreen)),
    ShackTagColor(label: "Blue", tag: "b{}b", color: Color(UIColor.systemBlue)),
    ShackTagColor(label: "Yellow", tag: "y{}y", color: Color("YellowText")),
    ShackTagColor(label: "Lime", tag: "l[]l", color: Color("LimeText")),
    ShackTagColor(label: "Orange", tag: "n[]n", color: Color(UIColor.systemOrange)),
    ShackTagColor(label: "Pink", tag: "p[]p", color: Color("PinkText")),
    ShackTagColor(label: "Olive", tag: "e[]e", color: Color("OliveText"))
]

struct TagTextView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var shown: Bool
    //var confirmAction: () -> Void = {}

    let columns = [
        GridItem(.adaptive(minimum: 60))
    ]

    var body: some View {
        if self.shown {
            VStack {
                Spacer()
                    LazyVGrid(columns: columns, spacing: 20) {
                        
                        // ----
                        
                        ForEach(ShackTagColors, id: \.self) { shacktag in
                            Button(action: {
                                ShackTags.shared.tagWith = shacktag.tag
                                ShackTags.shared.tagAction()
                                withAnimation(.easeOut(duration: 0.1)) {
                                    shown.toggle()
                                }
                            }) {
                                Text(shacktag.label)
                                    .bold()
                                    .foregroundColor(shacktag.color)
                            }
                            .frame(width: 60, height: 30)
                            .foregroundColor(.white)
                        }
                        
                        // ----
                        
                        Button(action: {
                            ShackTags.shared.tagWith = "/[]/"
                            ShackTags.shared.tagAction()
                            withAnimation(.easeOut(duration: 0.1)) {
                                shown.toggle()
                            }
                        }) {
                            Text("Italic")
                                .bold()
                                .italic()
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 30)
                        .foregroundColor(.white)
                        
                        Button(action: {
                            ShackTags.shared.tagWith = "b[]b"
                            ShackTags.shared.tagAction()
                            withAnimation(.easeOut(duration: 0.1)) {
                                shown.toggle()
                            }
                        }) {
                            Text("Bold")
                                .bold()
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 30)
                        .foregroundColor(.white)

                        Button(action: {
                            ShackTags.shared.tagWith = "_[]_"
                            ShackTags.shared.tagAction()
                            withAnimation(.easeOut(duration: 0.1)) {
                                shown.toggle()
                            }
                        }) {
                            Text("Under")
                                .bold()
                                .underline()
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 30)
                        .foregroundColor(.white)
                        
                        Button(action: {
                            ShackTags.shared.tagWith = "q[]q"
                            ShackTags.shared.tagAction()
                            withAnimation(.easeOut(duration: 0.1)) {
                                shown.toggle()
                            }
                        }) {
                            Text("Quote")
                                .bold()
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 30)
                        .foregroundColor(.white)
                        
                        // ----
                        
                        Button(action: {
                            ShackTags.shared.tagWith = "/{{}}/"
                            ShackTags.shared.tagAction()
                            withAnimation(.easeOut(duration: 0.1)) {
                                shown.toggle()
                            }
                        }) {
                            Text("Code")
                                .bold()
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 30)
                        .foregroundColor(.white)
                        
                        Button(action: {
                            ShackTags.shared.tagWith = "s[]s"
                            ShackTags.shared.tagAction()
                            withAnimation(.easeOut(duration: 0.1)) {
                                shown.toggle()
                            }
                        }) {
                            Text("Sample")
                                .bold()
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 30)
                        .foregroundColor(.white)
                        
                        Button(action: {
                            ShackTags.shared.tagWith = "-[]-"
                            ShackTags.shared.tagAction()
                            withAnimation(.easeOut(duration: 0.1)) {
                                shown.toggle()
                            }
                        }) {
                            Text("Strike")
                                .bold()
                                .strikethrough()
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 30)
                        .foregroundColor(.white)
                        
                        Button(action: {
                            ShackTags.shared.tagWith = "o[]o"
                            ShackTags.shared.tagAction()
                            withAnimation(.easeOut(duration: 0.1)) {
                                shown.toggle()
                            }
                        }) {
                            Text("Spoiler")
                                .bold()
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 30)
                        .foregroundColor(.white)
                        
                    }
                
                Spacer()
            }
            .frame(width: 290, height: 240)
            .background(colorScheme == .dark ? Color(UIColor.systemGray4).opacity(0.9) : Color.white.opacity(0.9))
            .cornerRadius(12)
            .clipped()
            .shadow(radius: 5)
            .transition(.scale)
        } else {
            EmptyView()
        }
    }
}

struct TagTextView_Previews: PreviewProvider {
    
    static var previews: some View {
        TagTextView(shown: .constant(true))
            .environment(\.colorScheme, .dark)
    }
}
