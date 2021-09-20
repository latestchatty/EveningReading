//
//  macOSInboxView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct macOSInboxView: View {
    @EnvironmentObject var messageService: MessageStore
    
    private func fetchMessages() {
        messageService.getMessages(page: "1", append: true, delay: 0)
    }
    
    var body: some View {
        HSplitView {
            // Inbox
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(messageService.messages, id: \.id) { message in
                        Text(message.subject)
                    }
                }
                .background(Color.purple)
            }
            .padding()
            .background(Color.green)
            .frame(minWidth: 400)
            
            // Selected Message
            VStack {
                Text("Selected message")
            }
            .padding()
            .background(Color.blue)
            .layoutPriority(1)
        }
        .background(Color.pink)
        .onAppear(perform: fetchMessages)
        .navigationTitle("Inbox")
        .toolbar() {
            ToolbarItemGroup(placement: .navigation) {
                Button(action: {
                    self.fetchMessages()
                }, label: {
                    Image(systemName: "arrow.counterclockwise")
                })
                Button(action: {
                    // compose
                }, label: {
                    Image(systemName: "square.and.pencil")
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}

struct macOSInboxView_Previews: PreviewProvider {
    static var previews: some View {
        macOSInboxView()
            .frame(width: 1920, height: 1080)
            .environmentObject(MessageStore(service: MessageService()))
    }
}
