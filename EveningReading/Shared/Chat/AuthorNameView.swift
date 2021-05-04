//
//  AuthorNameView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct AuthorNameView: View {
    @Binding var name: String
    
    var body: some View {
        #if os(iOS)
        Text("\(self.name)")
            .font(.footnote)
            .bold()
            .foregroundColor(Color(UIColor.systemOrange))
            .lineLimit(1)
            .contextMenu {
                Button(action: {
                    // send message
                }) {
                    Text("Send Message")
                    Image(systemName: "envelope.circle")
                }
                Button(action: {
                    // search posts
                }) {
                    Text("Search Post History")
                    Image(systemName: "magnifyingglass.circle")
                }
                Button(action: {
                    // report user
                }) {
                    Text("Report User")
                    Image(systemName: "exclamationmark.circle")
                }
            }
        #endif
        #if os(OSX)
        Text("\(self.name)")
            .font(.footnote)
            .bold()
            .foregroundColor(Color(NSColor.systemOrange))
            .lineLimit(1)
            .contextMenu {
                Button(action: {
                    // send message
                }) {
                    Text("Send Message")
                    Image(systemName: "envelope.circle")
                }
                Button(action: {
                    // search posts
                }) {
                    Text("Search Post History")
                    Image(systemName: "magnifyingglass.circle")
                }
                Button(action: {
                    // report user
                }) {
                    Text("Report User")
                    Image(systemName: "exclamationmark.circle")
                }
            }
        #endif
    }
}

struct AuthorNameView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorNameView(name: .constant("tamzyn"))
    }
}
