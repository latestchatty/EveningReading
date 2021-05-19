//
//  AuthorNameView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct AuthorNameView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @StateObject var msgStore = MessageStore(service: .init())
    
    var name: String = ""
    var postId: Int = 0
    var bold: Bool = false
    var navLink: Bool = false
    
    #if os(iOS)
    @State private var showingNewMessageView = false
    @State private var messageRecipient: String = ""
    @State private var messageSubject: String = ""
    @State private var messageBody: String = ""
    #endif
    
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
                .truncationMode(.tail)
                .fixedSize()
        #endif
        #if os(OSX)
            Text("\(self.name)")
                .font(self.bold ? .headline : .body)
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
            if self.navLink {
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

                NavigationLink(destination: watchOSAuthorView(name: .constant(self.name), postId: .constant(self.postId)).environmentObject(appSessionStore), isActive: self.$showingAuthor) {
                        EmptyView()
                }.frame(width: 0, height: 0)
            } else {
                VStack {
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
                }
                .alert(isPresented: self.$showingAuthor) {
                    Alert(title: Text("Block \(self.name)"), message: Text("For post \(self.postId)?"),
                          primaryButton: .default (Text("OK")) {
                            // report user
                            appSessionStore.blockedAuthors.append(self.name)
                          }, secondaryButton: .cancel()
                    )
                }
                /*
                // Block user
                VStack {
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
                }
                .alert(isPresented: self.$showingAuthor) {
                    Alert(title: Text("Report \(self.name)"), message: Text("For post \(self.postId)?"),
                          primaryButton: .default (Text("OK")) {
                            // report user
                            msgStore.submitComplaint(author: self.name, postId: self.postId)
                          }, secondaryButton: .cancel()
                    )
                }
                */
            }
        #endif
    }
}

struct AuthorNameView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorNameView(name: "tamzyn", postId: 999999996, bold: false)
            .environment(\.colorScheme, .light)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(MessageStore(service: MessageService()))
    }
}
