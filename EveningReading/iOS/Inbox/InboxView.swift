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
    
    @StateObject var messageViewModel = MessageViewModel()
    
    @State private var messages: [Message] = [Message]()
    @State private var showingNewMessageSheet: Bool = false
    @State private var showRedacted: Bool = true
    @State private var showNoMessages: Bool = false
    
    private func getMessages() {
        if messageViewModel.messages.count > 0
        {
            return
        }
        messageViewModel.getMessages(page: 1, append: false, delay: 0)
    }
    
    private func allMessages() -> [Message] {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.showRedacted = false
        }
        return messageViewModel.messages
    }
    
    func getBackgroundColor(_ message: Message) -> Binding<Color> {
        var chatBubbleColor = Color("ChatBubblePrimary")
        if message.unread && !messageViewModel.markedMessages.contains(message.id) {
            chatBubbleColor = Color("ChatBubblePrimaryUnread")
        }
        return Binding(get: {chatBubbleColor}, set: {chatBubbleColor = $0})
    }
    
    func getForegroundColor(_ message: Message) -> Color {
        var chatBubbleTextColor = Color(UIColor.systemBlue)
        if message.unread && !messageViewModel.markedMessages.contains(message.id) {
            chatBubbleTextColor = Color(UIColor.systemYellow)
        }
        return chatBubbleTextColor
    }
    
    var body: some View {
        VStack {
            NewMessageView(showingNewMessageSheet: self.$showingNewMessageSheet)

            RefreshableScrollView(height: 70, refreshing: $messageViewModel.gettingMessages, scrollTarget: $messageViewModel.scrollTarget, scrollTargetTop: $messageViewModel.scrollTargetTop) {
                
                // No messages
                if (self.showNoMessages || !appSessionStore.isSignedIn || (messageViewModel.fetchComplete && messageViewModel.messages.count < 1)) && !self.showRedacted {
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
                    NavigationLink(destination: MessageDetailView(messageRecipient: message.from, messageSubject: message.subject, messageBody: message.body, messageId: message.id).environmentObject(messageViewModel)) {
                    
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
                               ChatBubble(direction: .left, bgcolor: getBackgroundColor(message)) {
                                   VStack(alignment: .leading) {
                                       HStack {
                                           Text(message.subject)
                                               .bold()
                                               .lineLimit(1)
                                               .font(.caption)
                                               .foregroundColor(getForegroundColor(message))
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
                                           .multilineTextAlignment(.leading)
                                           .padding(.init(top: 5, leading: 20, bottom: 20, trailing: 20))
                                           .foregroundColor(Color(UIColor.label))
                                   }
                               }
                               .padding(.trailing, 10)
                           }
                       }
                        
                    }
                    .conditionalModifier(self.showRedacted, RedactedModifier())
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                    .id(message.id)
                }
                
                // Padding to show all of the last message
                VStack {
                    Spacer().frame(width: UIScreen.main.bounds.width, height: 30)
                }
                .id(9999999999993)
            }
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
