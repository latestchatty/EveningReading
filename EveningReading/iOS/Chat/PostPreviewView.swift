//
//  PostPreviewView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/11/21.
//

import SwiftUI

struct PostPreviewView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    var username: String
    var postId: Int
    var postBody: String
    var replyLines: String
    var postCategory: String
    var postStrength: Double?
    var postAuthor: String
    var postLols: [ChatLols]
    
    var body: some View {
        HStack {
            // Reply lines for eaiser reading
            Text(self.replyLines)
                .lineLimit(1)
                .fixedSize()
                .font(.custom("replylines", size: 25, relativeTo: .callout))
                .foregroundColor(Color("replyLines"))
            
            // Rarely a post category is set on a reply
            if self.postCategory == "nws" {
                Text("nws")
                    .bold()
                    .lineLimit(1)
                    .font(.footnote)
                    .foregroundColor(Color(UIColor.systemRed))
            } else if self.postCategory == "stupid" {
                Text("stupid")
                    .bold()
                    .lineLimit(1)
                    .font(.footnote)
                    .foregroundColor(Color(UIColor.systemGreen))
            } else if self.postCategory == "informative" {
                Text("inf")
                    .bold()
                    .lineLimit(1)
                    .font(.footnote)
                    .foregroundColor(Color(UIColor.systemBlue))
            }
            
            // One line preview of body
            Text(self.postBody.getPreview)
                .fontWeight(postStrength != nil ? PostWeight[postStrength!] : .regular)
                .lineLimit(1)
                .truncationMode(.tail)
                .font(.callout)
                .foregroundColor(self.username == self.postAuthor ? Color(UIColor.systemTeal) : (colorScheme == .dark ? Color(UIColor.white) : Color(UIColor.black)))
                .opacity(postStrength != nil ? postStrength! : 0.75)
                .frame(maxWidth: .infinity, alignment: .leading)
         
            
            // Maybe show post author
            if self.appSessionStore.displayPostAuthor {
                AuthorNameView(name: postAuthor, postId: postId)
            }
            
            // Tags/Lols
            LolView(lols: postLols, postId: postId)
        }
    }
}

struct PostPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PostPreviewView(username: "aenean", postId: 0, postBody: "This is a post.", replyLines: "A", postCategory: "ontopic", postStrength: 0.75, postAuthor: "aenean", postLols: [ChatLols]())
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
