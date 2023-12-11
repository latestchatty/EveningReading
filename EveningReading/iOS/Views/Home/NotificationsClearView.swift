//
//  NotificationsClearView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct NotificationsClearView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appService: AppService
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(" ")
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
            }
            .frame(alignment: .leading)
            .padding(EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 0))
            Button(action: {
                appService.pushNotifications.removeAll()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .imageScale(.small)
                    .foregroundColor(.white)
                    .frame(width: 22)
                    .padding(.trailing, 20)
            }
        }
        .background(Color("ArticleCardBackground"))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 10)
        .padding(.trailing, -2)
    }
}
