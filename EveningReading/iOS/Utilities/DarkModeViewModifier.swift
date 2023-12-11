//
//  DarkModeViewModifier.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/9/21.
//

import Foundation
import SwiftUI

public struct DarkModeViewModifier: ViewModifier {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true

    public func body(content: Content) -> some View {
        content
            .environment(\.colorScheme, isDarkMode ? .dark : .light)
            .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct SystemColor: Hashable {
    var text: String
    var color: Color
}

struct DarkModeColorView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true

    let backgroundColors: [SystemColor] = [.init(text: "Red", color: Color(UIColor.systemRed)), .init(text: "Orange", color: Color(UIColor.systemOrange)), .init(text: "Yellow", color: Color(UIColor.systemYellow)), .init(text: "Green", color: Color(UIColor.systemGreen)), .init(text: "Teal", color: Color(UIColor.systemTeal)), .init(text: "Blue", color: Color(UIColor.systemBlue)), .init(text: "Indigo", color: Color(UIColor.systemIndigo)), .init(text: "Purple", color: Color(UIColor.systemPurple)), .init(text: "Pink", color: Color(UIColor.systemPink)), .init(text: "Gray", color: Color(UIColor.systemGray)), .init(text: "Gray2", color: Color(UIColor.systemGray2)), .init(text: "Gray3", color: Color(UIColor.systemGray3)), .init(text: "Gray4", color: Color(UIColor.systemGray4)), .init(text: "Gray5", color: Color(UIColor.systemGray5)), .init(text: "Gray6", color: Color(UIColor.systemGray6))]
    
    var body: some View {
        Form {
            Section(header: Text("Common Colors")) {
                ForEach(backgroundColors, id: \.self) {
                    ColorRow(color: $0)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) { // navigation bar
               Picker("Color", selection: $isDarkMode) {
                    Text("Light").tag(false)
                    Text("Dark").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .modifier(DarkModeViewModifier())
    }
}

private struct ColorRow: View {
    let color: SystemColor

    var body: some View {
        HStack {
            Text(color.text)
            Spacer()
            Rectangle()
                .foregroundColor(color.color)
                .frame(width: 30, height: 30)
        }
    }
}
