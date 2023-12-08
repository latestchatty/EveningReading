//
//  FavoriteContributedView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 3/29/23.
//

import SwiftUI

struct FavoriteContributedView: View {
    @Binding var contributed: Bool
    
    var body: some View {
        if self.contributed {
            #if os(iOS)
                Image(systemName: "star")
                    .imageScale(.small)
                    .foregroundColor(Color(UIColor.systemRed))
                    .offset(x: 0, y: -1)
            #endif
            #if os(OSX)
                Image(systemName: "star")
                    .imageScale(.medium)
                    .foregroundColor(Color(NSColor.systemRed))
                    .offset(x: 0, y: -1)
            #endif
            #if os(watchOS)
                Image(systemName: "star")
                    .imageScale(.small)
                    .foregroundColor(Color.red)
                    .offset(x: 0, y: -1)
            #endif
        }
    }
}
