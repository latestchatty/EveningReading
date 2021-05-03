//
//  macOSChatView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct macOSChatView: View {
    var body: some View {
        VStack {
            Text("Chat View")
            Text("[insert here]").padding()
        }
        .navigationTitle("Chat")
    }
}

struct macOSChatView_Previews: PreviewProvider {
    static var previews: some View {
        macOSChatView()
    }
}
