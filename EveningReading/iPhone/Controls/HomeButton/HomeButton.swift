//
//  HomeButton.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct HomeButton: View {
    @Environment(\.colorScheme) var colorScheme
    var title: String
    var imageName: String
    var buttonBackground: Color

    var body: some View {
        VStack {
            VStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .imageScale(.small)
                    .frame(width: 40)
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

struct HomeButton_Previews: PreviewProvider {
    static var previews: some View {
        HomeButton(title: "Chat", imageName: "glyphicons-basic-238-chat-message", buttonBackground: Color("HomeButtonChat"))
    }
}
