//
//  NotificationPreviewView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct NotificationPreviewView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSession: AppSession
    var title: String
    var postBody: String
    var postId: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(UIColor.systemOrange))
                    .lineLimit(1)
            }
            .frame(alignment: .leading)
            .padding(EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10))
            Spacer()
            Text("\(self.postBody)")
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(2)
                .padding(.trailing, 20)
            Spacer()
        }
        .background(Color("ArticleCardBackground"))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 10)
        .frame(maxWidth: 350)
        .padding(.trailing, -2)
    }
}
