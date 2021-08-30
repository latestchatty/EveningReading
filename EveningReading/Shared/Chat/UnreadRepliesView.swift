//
//  NewRepliesView.swift
//  EveningReading
//
//  Created by Willie Zutz on 8/29/21.
//

import SwiftUI

struct UnreadRepliesView: View {
    var hasUnreadReplies: Bool = false
    
    var body: some View {
        if self.hasUnreadReplies {
            #if os(iOS)
                Image(systemName: "star.fill")
                    .imageScale(.small)
                    .foregroundColor(Color(UIColor.systemTeal))
                    .offset(x: 0, y: -1)
            #endif
            #if os(OSX)
                Image(systemName: "star.fill")
                    .imageScale(.medium)
                    .foregroundColor(Color.accentColor)
                    .offset(x: 0, y: -1)
            #endif
            #if os(watchOS)
                Image(systemName: "star.fill")
                    .imageScale(.small)
                    .foregroundColor(Color.blue)
                    .offset(x: 0, y: -1)
            #endif
        }
    }
}

struct UnreadRepliesView_Previews: PreviewProvider {
    static var previews: some View {
        UnreadRepliesView(hasUnreadReplies: true)
    }
}
