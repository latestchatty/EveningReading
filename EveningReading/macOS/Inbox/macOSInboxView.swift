//
//  macOSInboxView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct macOSInboxView: View {
    @EnvironmentObject var messageStore: MessageStore
    
    var body: some View {
        VStack {
            Text("Inbox View")
            Text("[insert here]").padding()
        }
        .navigationTitle("Inbox")
    }
}
