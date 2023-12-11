//
//  TagTextView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/26/21.
//

import Foundation
import SwiftUI

struct TagTextView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var shackTagViewModel = ShackTagViewModel()
    
    @Binding var shown: Bool
    
    let columns = [
        GridItem(.adaptive(minimum: 60))
    ]
    
    func tagAndHide() {
        ShackTags.shared.tagAction()
        withAnimation(.easeOut(duration: 0.1)) {
            shown.toggle()
        }
    }
    
    var body: some View {
        if self.shown {
            VStack {
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 20) {
                    
                    ForEach(shackTagViewModel.tagColors, id: \.self) { shacktag in
                        Button(action: {
                            ShackTags.shared.tagWith = shacktag.tag
                            tagAndHide()
                        }) {
                            Text(shacktag.label)
                                .bold()
                                .foregroundColor(shacktag.color)
                        }
                        .frame(width: 60, height: 30)
                        .foregroundColor(.white)
                    }
                    
                    ForEach(shackTagViewModel.tagFormats, id: \.self) { shacktag in
                        Button(action: {
                            ShackTags.shared.tagWith = shacktag.tag
                            tagAndHide()
                        }) {
                            Text(shacktag.label)
                                .bold()
                                .foregroundColor(.primary)
                        }
                        .frame(width: 60, height: 30)
                        .foregroundColor(.white)
                    }
                    
                }
                                
                Rectangle()
                    .fill(Color(UIColor.systemGray2))
                    .frame(height: 1)
            
                Text("Cancel")
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 260, height: 30)
                    .contentShape(Rectangle())
                    .offset(x: 0, y: 2)
                    .onTapGesture(count: 1) {
                        withAnimation(.easeOut(duration: 0.1)) {
                            shown.toggle()
                        }
                    }
                
                Spacer()
            }
            .frame(width: 290, height: 280)
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
