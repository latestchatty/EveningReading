//
//  watchOSAuthorView.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct watchOSAuthorView: View {
    @EnvironmentObject var appService: AppService
    
    @StateObject var messageViewModel = MessageViewModel()
    
    @Binding var name: String
    @Binding var postId: Int

    @State private var showReportUserMessage: Bool = false
    @State private var showMessageSent: Bool = false
    @State private var showBlocked: Bool = false
    
    var body: some View {        
        VStack {
            // Fixes navigation bug
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
                        Text("', author of post https://www.shacknews.com/chatty?id=\(String(self.postId))#item_\(String(self.postId)) for not adhering to the Shacknews guidelines.")
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
                        messageViewModel.submitComplaint(author: self.name, postId: self.postId)
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
                        appService.blockedAuthors.append(self.name)
                        self.showBlocked = true
                    }
                }
            }
        }
    }
}
