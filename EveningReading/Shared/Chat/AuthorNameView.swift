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
    @Binding var postId: Int
    
    #if os(watchOS)
    @State private var showingAuthor = false
    #endif
    
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
                self.showingAuthor.toggle()
            }) {
                Text("\(self.name)")
                    .font(.footnote)
                    .bold()
                    .foregroundColor(Color.orange)
                    .lineLimit(1)
            }
            .buttonStyle(PlainButtonStyle())

        NavigationLink(destination: watchOSAuthorView(name: .constant(self.name), postId: .constant(self.postId)), isActive: self.$showingAuthor) {
                EmptyView()
        }.frame(width: 0, height: 0)
        #endif
    }
}

struct AuthorNameView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorNameView(name: .constant("tamzyn"), postId: .constant(9999999996))
            .environment(\.colorScheme, .light)
    }
}
