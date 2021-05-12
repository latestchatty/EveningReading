//
//  InboxView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct InboxView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var messageStore: MessageStore

    @State private var messages: [Message] = [Message]()
    @State private var showingNewMessageSheet: Bool = false
    @State private var showRedacted: Bool = true
    @State private var showNoMessages: Bool = false
    
    private func getMessages() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil || self.messageStore.messages.count > 0
        {
            return
        }
        messageStore.getMessages(page: "1", append: false, delay: 0)
    }
    
    private func allMessages() -> [Message] {
        var msgs: [Message] = [Message]()
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            msgs = Array(messageData.messages)
        }
        else {
            msgs = self.messageStore.messages
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.showRedacted = false
        }
        return msgs
    }
    
    var body: some View {
        
        GoToPostView()
        
        NewMessageView(showingNewMessageSheet: self.$showingNewMessageSheet, messageId: Binding.constant(0), recipientName: Binding.constant(""), subjectText: Binding.constant(""), bodyText: Binding.constant(""))

        RefreshableScrollView(height: 70, refreshing: self.$messageStore.gettingMessages, scrollTarget: self.$messageStore.scrollTarget, scrollTargetTop: self.$messageStore.scrollTargetTop) {
            
            // No messages
            if (self.showNoMessages || !self.appSessionStore.isSignedIn || (self.messageStore.fetchComplete && self.messageStore.messages.count < 1)) && !self.showRedacted {
                VStack {
                    HStack {
                        Spacer()
                        Text("No Messages.")
                            .font(.body)
                            .bold()
                            .foregroundColor(Color("NoDataLabel"))
                            .padding(.vertical, 20)
                        Spacer()
                    }
                    Spacer()
                }
                .id(9999999999991)
            }
            
            // Messages
            ForEach(allMessages(), id: \.id) { message in
                NavigationLink(destination: MessageDetailView(messageRecipient: Binding.constant(message.from), messageSubject: Binding.constant(message.subject), messageBody: Binding.constant(message.body), messageId: .constant(message.id))) {
                
                    VStack {
                       HStack {
                           Text("\(message.from == "" ? "moderator" : message.from)")
                               .bold()
                               .lineLimit(1)
                               .truncationMode(.tail)
                               .fixedSize()
                               .font(.footnote)
                               .foregroundColor(Color(UIColor.systemOrange))
                               .padding(.horizontal, 15)
                           Spacer()
                           Text(message.date.fromISO8601())
                               .font(.footnote)
                               .lineLimit(1)
                               .foregroundColor(Color(UIColor.systemGray))
                               .padding(.trailing, 10)
                       }
                       HStack {
                           Spacer()
                           ChatBubble(direction: .left, bgcolor: (message.unread && !self.messageStore.markedMessages.contains(message.id) ? Color("ChatBubbleSecondary") :  Color("ChatBubblePrimary"))) {
                               VStack(alignment: .leading) {
                                   HStack {
                                       Text(message.subject)
                                           .bold()
                                           .lineLimit(1)
                                           .font(.caption)
                                           .foregroundColor(Color(UIColor.systemBlue))
                                           .padding(.init(top: 20, leading: 20, bottom: 5, trailing: 20))
                                       Spacer()
                                       Image(systemName: "chevron.right")
                                           .font(.callout)
                                           .foregroundColor(Color(UIColor.systemGray))
                                           .padding(.trailing, 20)
                                           .padding(.top, 17)
                                   }
                                   Text(message.body.getPreview)
                                       .lineLimit(3)
                                       .padding(.init(top: 5, leading: 20, bottom: 20, trailing: 20))
                                       .foregroundColor(Color(UIColor.label))
                               }
                           }
                           .padding(.trailing, 10)
                       }
                   }
                    
                }
                .conditionalModifier(self.showRedacted, RedactedModifier())
                .padding(.top, 30)
                .frame(maxWidth: .infinity)
                .id(message.id)
            }
            
        // Padding to show all of the last message
        VStack {
            Spacer().frame(width: UIScreen.main.bounds.width, height: 30)
        }
        .id(9999999999993)
            
        }
        .onAppear(perform: getMessages)
        .frame(maxWidth: .infinity)
        .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitle("Inbox", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 16, height: 16), trailing: NewMessageButton(isReply: false, showingNewMessageSheet: self.$showingNewMessageSheet))
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(MessageStore(service: MessageService()))
    }
}
