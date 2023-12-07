//
//  iPhoneHomeButton.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct iPhoneHomeButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var title: String
    @Binding var imageName: String
    @Binding var buttonBackground: Color

    var body: some View {
        VStack {
            VStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .imageScale(.small)
                    .frame(width: 40)
                    .padding(.top, title == "Inbox" ? 7 : 0)
            }
            .frame(width: 64, height: 64)
            .background(buttonBackground)
            .foregroundColor(.black)
            .cornerRadius(10)
            .shadow(color: Color("HomeButtonShadow"), radius: 10, x: 0, y: 10)
            .padding(.bottom, 5)
            
            Text(title)
                .font(.body)
                .bold()
                .foregroundColor(.primary)
        }
        .frame(width: 84)
    }
}
