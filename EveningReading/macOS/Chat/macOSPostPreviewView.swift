//
//  macOSPostPreviewView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/10/21.
//

import SwiftUI

struct macOSPostPreviewView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @Binding var postId: Int
    @Binding var postAuthor: String
    @Binding var replyLines: String?
    @Binding var lols: [ChatLols]
    @Binding var postText: String
    @Binding var postCategory: String
    @Binding var postStrength: Double?
    @Binding var op: String

    var body: some View {
        // Reply lines
        Text(self.replyLines == nil ? String(repeating: " ", count: 5) : self.replyLines!)
            .lineLimit(1)
            .fixedSize()
            .font(.custom("replylines", size: 25, relativeTo: .callout))
            .foregroundColor(Color("replyLines"))
        
        // Category (rarely)
        if self.postCategory == "nws" {
            Text("nws")
                .bold()
                .lineLimit(1)
                .font(.footnote)
                .foregroundColor(Color(NSColor.systemRed))
        } else if self.postCategory == "stupid" {
            Text("stupid")
                .bold()
                .lineLimit(1)
                .font(.footnote)
                .foregroundColor(Color(NSColor.systemGreen))
        } else if self.postCategory == "informative" {
            Text("inf")
                .bold()
                .lineLimit(1)
                .font(.footnote)
                .foregroundColor(Color(NSColor.systemBlue))
        }
        
        // Post preview line
        Text("\(appSessionStore.blockedAuthors.contains(self.postAuthor) ? "[blocked]" : postText.getPreview)")
            .font(.body)
            .fontWeight(postStrength != nil ? PostWeight[postStrength!] : .regular)
            .opacity(postStrength != nil ? postStrength! : 0.75)
            .foregroundColor(appSessionStore.username.lowercased() == self.postAuthor.lowercased() ? Color(NSColor.systemTeal) : Color.primary)
            .lineLimit(1)
        Spacer()
        
        // Author
        AuthorNameView(name: self.postAuthor, postId: self.postId, op: self.op)
        
        // Lols
        LolView(lols: self.lols, postId: self.postId)
    }
}
