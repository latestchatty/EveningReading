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
    @EnvironmentObject var messageStore: MessageStore
    @EnvironmentObject var notifications: Notifications
    @Binding public var showingNewMessageSheet: Bool
    @Binding public var messageId: Int
    @Binding public var recipientName: String
    @Binding public var subjectText: String
    @Binding public var bodyText: String
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
            var replySpacing = ""
            if self.recipientName != "Duke Nuked" && self.bodyText != " " {
                replySpacing = "\n\n--------------------\n\n\(self.messageRecipient) Wrote:\n\n"
            }
            self.messageBodyText = replySpacing + self.bodyText.newlineToBR
        }
    }
    
    private func clearNewMessageSheet() {
        DispatchQueue.main.async {
            self.messageRecipient = ""
            self.messageBodyText = ""
            self.showingNewMessageSheet = false
        }
    }
    
    var body: some View {
        Spacer().frame(width:0, height: 0)
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
                            
                            self.messageStore.submitMessage(recipient: self.messageRecipient, subject: self.messageSubjectText, body: self.messageBodyText)
                            
                            self.messageRecipient = ""
                            self.messageBodyText = ""
                            self.showingNewMessageSheet = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
                            //self.showingSubmitAlert = true
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
                        .background(colorScheme == .light ? Color("ChatBubblePrimary") : Color(red: 227.0 / 255.0, green:  227.0 / 255.0, blue: 225.0 / 255.0))
                        .foregroundColor(Color.black)
                        .cornerRadius(4.0)
                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 15, trailing: 5))
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
                        .background(colorScheme == .light ? Color("ChatBubblePrimary") : Color(red: 227.0 / 255.0, green:  227.0 / 255.0, blue: 225.0 / 255.0))
                        .foregroundColor(Color.black)
                        .cornerRadius(4.0)
                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 15, trailing: 5))
                }
                
                // TextEditor
                // no way to change the background yet :(
                if colorScheme == .light {
                    TextEditor(text: self.$messageBodyText)
                        .border(Color(UIColor.systemGray5))
                        .cornerRadius(4.0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                } else {
                    TextEditor(text: self.$messageBodyText)
                        .border(Color(UIColor.systemGray5))
                        .cornerRadius(4.0)
                        .colorInvert()
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

struct NewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NewMessageView(showingNewMessageSheet: .constant(false), messageId: Binding.constant(0), recipientName: Binding.constant(""), subjectText: Binding.constant(""), bodyText: Binding.constant(""))
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(MessageStore(service: MessageService()))
            .environmentObject(Notifications())
    }
}
