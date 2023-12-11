//
//  NewMessageView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/9/21.
//

import SwiftUI

struct NewMessageView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var notifications: Notifications
    
    @StateObject var messageViewModel = MessageViewModel()
    
    @Binding public var showingNewMessageSheet: Bool
    public var messageId: Int = 0
    public var recipientName: String = ""
    public var subjectText: String = ""
    public var bodyText: String = ""
    
    @State private var messageRecipient = ""
    @State private var messageSubjectText = ""
    @State private var messageBodyText = ""

    func newMessageAppear() {
        if self.recipientName != "" {
            self.messageRecipient = self.recipientName
        }
        if self.subjectText != "" {
            self.messageSubjectText = self.subjectText
        }
        if self.bodyText != "" {
            self.messageBodyText = messageViewModel.formatReply(recipient: self.messageRecipient, body: self.bodyText)
        }
    }
    
    private func clearNewMessageSheet() {
        DispatchQueue.main.async {
            self.messageRecipient = ""
            self.messageSubjectText = ""
            self.messageBodyText = ""
            self.showingNewMessageSheet = false
        }
    }
    
    var body: some View {
        Spacer().frame(width: 0, height: 0)
        .sheet(isPresented: $showingNewMessageSheet) {
            VStack {                
                // Buttons
                HStack {
                    Spacer().frame(width: 10)
                    // Cancel
                    Button("Cancel") {
                        clearNewMessageSheet()
                    }
                    Spacer()
                    
                    // Send
                    Button("Send") {
                        DispatchQueue.main.async {
                            messageViewModel.submitMessage(recipient: self.messageRecipient, subject: self.messageSubjectText, body: self.messageBodyText)
                            self.messageRecipient = ""
                            self.messageSubjectText = ""
                            self.messageBodyText = ""
                            self.showingNewMessageSheet = false
                        }
                    }
                    .frame(width: 70, height: 30)
                    Spacer().frame(width: 10)
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
                .onAppear(perform: newMessageAppear)
                
                // Recipient
                HStack(alignment: .center) {
                    Text("Recipient")
                        .frame(width: 95)
                        .padding(.leading, 5)
                        .padding(.bottom, 12)
                    Spacer()
                    TextField("", text: $messageRecipient)
                        .padding(10)
                        .multilineTextAlignment(.leading)
                        .background(colorScheme == .light ? Color("ChatBubblePrimary") : Color(red: 227.0 / 255.0, green:  227.0 / 255.0, blue: 225.0 / 255.0))
                        .foregroundColor(Color.black)
                        .cornerRadius(4.0)
                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 15, trailing: 5))
                        .disableAutocorrection(true)
                }
                
                // Subject
                HStack(alignment: .center) {
                    Text("Subject   ")
                        .frame(width: 95)
                        .padding(.leading, 5)
                        .padding(.bottom, 12)
                    Spacer()
                    TextField("", text: self.$messageSubjectText)
                        .padding(10)
                        .multilineTextAlignment(.leading)
                        .background(colorScheme == .light ? Color("ChatBubblePrimary") : Color(red: 227.0 / 255.0, green:  227.0 / 255.0, blue: 225.0 / 255.0))
                        .foregroundColor(Color.black)
                        .cornerRadius(4.0)
                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 15, trailing: 5))
                }
                
                // TextEditor
                // No way to change the background with supported iOS versions
                if colorScheme == .light {
                    TextEditor(text: self.$messageBodyText)
                        .border(Color(UIColor.systemGray5))
                        .cornerRadius(4.0)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                } else {
                    TextEditor(text: self.$messageBodyText)
                        .border(Color(UIColor.systemGray5))
                        .cornerRadius(4.0)
                        .colorInvert()
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                }
                
            }
        }
        
        // If push notification tapped
        .onReceive(notifications.$notificationData) { value in
            if value != nil {
                clearNewMessageSheet()
            }
        }
        
    }
}
