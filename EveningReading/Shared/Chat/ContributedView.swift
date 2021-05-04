//
//  ContributedView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct ContributedView: View {
    @Binding var contributed: Bool
    
    var body: some View {
        if self.contributed {
            #if os(iOS)
                Image(systemName: "pencil")
                    .imageScale(.small)
                    .foregroundColor(Color(UIColor.systemTeal))
                    .padding(.leading, 5)
                    .offset(x: 0, y: -1)
            #endif
            #if os(OSX)
                Image(systemName: "pencil")
                    .imageScale(.small)
                    .foregroundColor(Color(NSColor.systemTeal))
                    .padding(.leading, 5)
                    .offset(x: 0, y: -1)
            #endif
        }
        Spacer()
    }
}

struct ContributedView_Previews: PreviewProvider {
    static var previews: some View {
        ContributedView(contributed: .constant(true))
    }
}
