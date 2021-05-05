//
//  watchOSReplyButton.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct watchOSReplyButton: View {
    @Binding var replyId: Int
    @Binding var replyText: String
    
    @State private var showPost: Bool = false
    
    var body: some View {
        HStack {
            Button(action: {
                // go to post
                self.showPost.toggle()
            }) {
                HStack {
                    Text("\(self.replyText)")
                        .font(.footnote)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding()
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            .background(Color("ThreadBubbleSecondary"))
            .cornerRadius(5)
            
            NavigationLink(destination: watchOsPostDetail(postId: .constant(self.replyId)), isActive: self.$showPost) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
        }
    }
}

struct watchOSReplyButton_Previews: PreviewProvider {
    static var previews: some View {
        watchOSReplyButton(replyId: .constant(9999999992), replyText: .constant("Quis hendrerit dolor magna eget."))
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
    }
}

