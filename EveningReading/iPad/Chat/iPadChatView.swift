//
//  iPadChatView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct iPadChatView: View {
    var body: some View {
        LazyVStack {
            Text("iPad Chat View")
        }
        .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Chat", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 26, height: 16))
    }
}

struct iPadChatView_Previews: PreviewProvider {
    static var previews: some View {
        iPadChatView()
    }
}
