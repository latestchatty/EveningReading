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
    
    @StateObject var messageViewModel = MessageViewModel()
    
    var name: String = ""
    var postId: Int = 0
    var bold: Bool = false
    var navLink: Bool = false
    var op: String = ""
    
    #if os(iOS)
    @State private var showingNewMessageView = false
    @State private var messageRecipient: String = ""
    @State private var messageSubject: String = ""
    @State private var messageBody: String = ""
    #endif
    
    #if os(macOS)
    @State private var showingBlockUser = false
    #endif
    
    #if os(watchOS)
    @State private var showingAuthor = false
    #endif
    
    var body: some View {
        #if os(iOS)
            Text("\(self.name)")
                .font(.footnote)
                .bold()
                .foregroundColor(
                    self.name == self.op ? Color(UIColor.systemGreen) : self.name == "Shacknews" ? Color(UIColor.systemBlue) : appSessionStore.favoriteAuthors.contains(self.name) ? Color(UIColor.systemRed) : Color(UIColor.systemOrange)
                )
                .lineLimit(1)
                .truncationMode(.tail)
                .fixedSize()
        #endif
        #if os(OSX)
            Text("\(appSessionStore.blockedAuthors.contains(self.name) ? "[blocked]" : self.name)")
                .font(self.bold ? .headline : .body)
                .foregroundColor(
                    self.name == self.op ? Color(NSColor.systemGreen) : self.name == "Shacknews" ? Color(NSColor.systemBlue) : colorScheme == .dark ? Color(NSColor.systemOrange) : Color(NSColor.systemPurple)
                )
                .lineLimit(1)
                .fixedSize()
                .contextMenu {
                    /*
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
                    */
                    Button(action: {
                        // report user
                        appSessionStore.reportAuthorName = self.name
                        appSessionStore.showingReportUserSheet = true
                        appSessionStore.reportAuthorForPostId = self.postId
                    }) {
                        Text("Report User")
                        Image(systemName: "exclamationmark.circle")
                    }
                    Button(action: {
                        // block user
                        self.showingBlockUser = true
                    }) {
                        Text("Block User")
                        Image(systemName: "exclamationmark.circle")
                    }
                    
                }
                .alert(isPresented: self.$showingBlockUser) {
                    Alert(title: Text("Block \(self.name)?"), message: Text("For post " + String(self.postId)), primaryButton: .destructive(Text("Yes")) {
                        appSessionStore.blockedAuthors.append(self.name)
                    }, secondaryButton: .cancel() {
                        
                    })
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
                        .foregroundColor(self.name == "Shacknews" ? Color.blue : Color.orange)
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
                    Alert(title: Text("Block \(self.name)"), message: Text("For post " + String(self.postId)),
                          primaryButton: .default (Text("OK")) {
                            // report user
                            appSessionStore.blockedAuthors.append(self.name)
                          }, secondaryButton: .cancel()
                    )
                }
            }
        #endif
    }
}

