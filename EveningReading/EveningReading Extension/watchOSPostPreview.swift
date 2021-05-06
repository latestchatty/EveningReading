//
//  watchOSPostPreview.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct watchOSPostPreview: View {
    @Binding var postId: Int
    @Binding var replyText: String
    
    @State private var showingPost: Bool = false
    
    var body: some View {
        HStack {
            Button(action: {
                self.showingPost.toggle()
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
            
            NavigationLink(destination: watchOsPostDetail(postId: .constant(self.postId)), isActive: self.$showingPost) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
        }
    }
}

struct watchOSPostPreview_Previews: PreviewProvider {
    static var previews: some View {
        watchOSPostPreview(postId: .constant(9999999992), replyText: .constant("Quis hendrerit dolor magna eget."))
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
    }
}
