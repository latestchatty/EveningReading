//
//  watchOSAuthorView.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct watchOSAuthorView: View {
    @Binding var name: String
    @Binding var postId: Int

    @State private var showReportUserMessage: Bool = false
    @State private var showMessageSent: Bool = false
    
    var body: some View {        
        VStack {
            if self.showReportUserMessage {
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
                Text("User Reported!")
            } else {
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
            }
        }
    }
}

struct watchOSAuthorView_Previews: PreviewProvider {
    static var previews: some View {
        watchOSAuthorView(name: .constant("ellawala"), postId: .constant(999999996))
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
    }
}
