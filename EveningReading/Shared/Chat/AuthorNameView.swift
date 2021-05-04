//
//  AuthorNameView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct AuthorNameView: View {
    @Environment(\.colorScheme) var colorScheme
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
                .font(.body)
                .bold()
                .foregroundColor(colorScheme == .dark ? Color(NSColor.systemOrange) : Color(NSColor.systemPurple))
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
        #if os(watchOS)
            Button(action: {
                // report user
            }) {
                Text("\(self.name)")
                    .font(.footnote)
                    .bold()
                    .foregroundColor(Color.orange)
                    .lineLimit(1)
            }
            .buttonStyle(PlainButtonStyle())
        #endif
    }
}

struct AuthorNameView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorNameView(name: .constant("tamzyn"))
            .environment(\.colorScheme, .light)
    }
}
