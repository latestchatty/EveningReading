//
//  watchOSAuthorView.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct watchOSAuthorView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @StateObject var msgStore = MessageStore(service: .init())
    
    @Binding var name: String
    @Binding var postId: Int

    @State private var showReportUserMessage: Bool = false
    @State private var showMessageSent: Bool = false
    @State private var showBlocked: Bool = false
    
    var body: some View {        
        VStack {
            // Fixes navigation bug
            // https://developer.apple.com/forums/thread/677333
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.frame(width: 0, height: 0)            
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.frame(width: 0, height: 0)
            
            if self.showReportUserMessage {
                // Message
                ScrollView {
                    Text("I would like to report user '").font(.footnote) +
                    Text("\(self.name)").font(.footnote).foregroundColor(Color.orange) +
                        Text("', author of post http://www.shacknews.com/chatty?id=\(self.postId)#item_\(self.postId) for not adhering to the Shacknews guidelines.")
                        .font(.footnote)
                    Spacer()
                    Button("Send") {
                        // Send message
                        withAnimation {
                            self.showMessageSent = true
                            self.showReportUserMessage = false
                        }
                    }
                }
            } else if self.showMessageSent {
                // Author was reported
                Text("User Reported!")
                    .onAppear() {
                        msgStore.submitComplaint(author: self.name, postId: self.postId)
                    }
            } else if self.showBlocked {
                // Author was reported
                Text("User Blocked!")
            } else {
                // Prompt
                Spacer()
                Text("\(self.name)")
                    .font(.footnote)
                    .bold()
                    .foregroundColor(Color.orange)
                    .lineLimit(1)
                    .padding(.top)
                
                Spacer()
                Button("Report User") {
                    // Show message
                    withAnimation {
                        self.showReportUserMessage = true
                    }
                }
                Button("Block User") {
                    // Show message
                    withAnimation {
                        appSessionStore.blockedAuthors.append(self.name)
                        self.showBlocked = true
                    }
                }
            }
        }
    }
}

struct watchOSAuthorView_Previews: PreviewProvider {
    static var previews: some View {
        watchOSAuthorView(name: .constant("ellawala"), postId: .constant(999999996))
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(MessageStore(service: MessageService()))
    }
}
