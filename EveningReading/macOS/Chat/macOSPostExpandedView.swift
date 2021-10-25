//
//  macOSPostExpandedView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/10/21.
//

import SwiftUI

struct macOSPostExpandedView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @Binding var postId: Int
    @Binding var postAuthor: String
    @Binding var replyLines: String?
    @Binding var lols: [ChatLols]
    @Binding var postText: [RichTextBlock]

    var body: some View {
        HStack {
            // Reply lines
            Text(self.replyLines == nil ? String(repeating: " ", count: 5) : self.replyLines!)
                .lineLimit(1)
                .fixedSize()
                .font(.custom("replylines", size: 25, relativeTo: .callout))
                .foregroundColor(Color("replyLines"))
            
            // Author
            AuthorNameView(name: self.postAuthor, postId: self.postId)
            
            Spacer()
            
            // Lols
            LolView(lols: self.lols, expanded: true, postId: self.postId)
                .padding(.top, 5)
        }
        HStack {
            VStack (alignment: .leading) {
                // Full post
                RichTextView(topBlocks: self.postText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(8)

                if appSessionStore.isSignedIn {
                    HStack {
                        Spacer()
                        Image(systemName: "tag")
                            .imageScale(.large)
                            .onTapGesture(count: 1) {
                            }
                        Image(systemName: "arrowshape.turn.up.left")
                            .imageScale(.large)
                            .onTapGesture(count: 1) {
                            }
                    }
                    .padding(.bottom, 8)
                    .padding(.trailing, 8)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color("ThreadBubblePrimary"))
        .cornerRadius(5)
    }
}

struct macOSPostExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        macOSPostExpandedView(postId: .constant(0), postAuthor: .constant(""), replyLines: .constant(""), lols: .constant([ChatLols]()), postText: .constant([RichTextBlock]()))
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
