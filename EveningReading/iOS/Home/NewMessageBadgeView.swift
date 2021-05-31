//
//  NewMessageBadgeView.swift
//  iOS
//
//  Created by Chris Hodge on 9/2/20.
//

import SwiftUI

struct NewMessageBadgeView: View {
    @ScaledMetric(relativeTo: .body) var imageSize: CGFloat = 24
    @Binding var notificationNumber: Int
    
    var body: some View {
        if notificationNumber > 0 {
            ZStack {
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                    .foregroundColor(Color(UIColor.systemRed))
                Text(String(notificationNumber))
                    .foregroundColor(Color.white)
                    .font(.caption)
                    .bold()
            }
            .padding(.top, -12)
            .padding(.leading, 60)
        } else {
            EmptyView()
        }
    }
}

struct NewMessageBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        NewMessageBadgeView(notificationNumber: Binding.constant(13))
    }
}
