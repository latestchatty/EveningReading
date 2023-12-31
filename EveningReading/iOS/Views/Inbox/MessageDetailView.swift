//
//  MessageDetailView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/9/21.
//

import SwiftUI

struct MessageDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var messageViewModel: MessageViewModel
    
    public var messageRecipient: String
    public var messageSubject: String
    public var messageBody: String
    public var messageId: Int
    
    @State private var showingNewMessageSheet: Bool = false
    @State private var hyperlinkUrl: String?
    @State private var showingWebView = false
    @State private var messageWebViewHeight: CGFloat = .zero
    
    func markMessage() {
        DispatchQueue.main.async {
            messageViewModel.markMessage(messageId: self.messageId)
        }
    }
    
    var body: some View {
        VStack {
            NewMessageView(showingNewMessageSheet: self.$showingNewMessageSheet, messageId: self.messageId, recipientName: self.messageRecipient, subjectText: "Re: \(self.messageSubject)", bodyText: "\(self.messageBody.stringByDecodingHTMLEntities.newlineToBR) ")
            ScrollView {
                VStack {
                    HStack(alignment: .center) {
                        Text("From: ") +
                        Text("\(messageRecipient)")
                            .foregroundColor(Color(UIColor.systemOrange))
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    Divider()
                    HStack(alignment: .center) {
                        Text(messageSubject)
                            .foregroundColor(Color(UIColor.systemBlue))
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    Divider()
                }
                .padding(.top, 10)
                VStack {
                    HStack {
                        MessageWebView(viewModel: MessageWebViewModel(body: messageBody, colorScheme: colorScheme), hyperlinkUrl: $hyperlinkUrl, showingWebView: $showingWebView, dynamicHeight: $messageWebViewHeight)
                    }
                    .frame(height: self.messageWebViewHeight)
                    Spacer()
                }
                .padding(.horizontal, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear(perform: markMessage)
        .background(Color("PrimaryBackground").frame(height: BackgroundHeight).offset(y: BackgroundOffset))
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitle("Inbox", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 16, height: 16), trailing:
            Button(action: {
                DispatchQueue.main.async {
                    self.showingNewMessageSheet = true
                }
            }) {
                Image(systemName: "arrowshape.turn.up.left")
                    .imageScale(.large)
                    .foregroundColor(self.colorScheme == .dark ? Color(UIColor.white) : Color(UIColor.systemBlue))
            }
        )
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
}
