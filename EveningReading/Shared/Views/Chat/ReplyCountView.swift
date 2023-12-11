//
//  ReplyCountView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct ReplyCountView: View {
    var replyCount: Int
    
    var body: some View {
        #if os(iOS)
            Text("\(self.replyCount)")
                .font(.footnote)
                .foregroundColor(Color(UIColor.systemGray)) +
            Text(self.replyCount == 1 ? " Reply" : " Replies")
                    .font(.footnote)
                    .foregroundColor(Color(UIColor.systemGray))
        #endif
        #if os(OSX)
            Text(self.replyCount == 1 ? "\(self.replyCount) Reply" : "\(self.replyCount) Replies")
                .foregroundColor(Color(NSColor.systemGray))
                .font(.body)
                .lineLimit(1)
                .fixedSize()
        #endif
        #if os(watchOS)
            Text("(\(self.replyCount))")
                .font(.footnote)
                .foregroundColor(Color.gray)
        #endif
    }
}
