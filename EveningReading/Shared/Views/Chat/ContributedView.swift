//
//  ContributedView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct ContributedView: View {
    var contributed: Bool = false
    
    var body: some View {
        if self.contributed {
            #if os(iOS)
                Image(systemName: "pencil")
                    .imageScale(.small)
                    .foregroundColor(Color(UIColor.systemTeal))
                    .offset(x: 0, y: -1)
            #endif
            #if os(OSX)
                Image(systemName: "pencil")
                    .imageScale(.medium)
                    .foregroundColor(Color(NSColor.systemTeal))
                    .offset(x: 0, y: -1)
            #endif
            #if os(watchOS)
                Image(systemName: "pencil")
                    .imageScale(.small)
                    .foregroundColor(Color.blue)
                    .offset(x: 0, y: -1)
            #endif
        }
    }
}

