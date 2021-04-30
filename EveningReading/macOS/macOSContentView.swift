//
//  ContentView.swift
//  Shared
//
//  Created by Chris Hodge on 4/28/21.
//

import SwiftUI

struct macOSWindowSize {
    let minWidth : CGFloat = 800
    let minHeight : CGFloat = 600
}

struct macOSContentView: View {
    var body: some View {
        VStack() {
            Text("Evening Reading macOS!")
                .padding()
        }
        .frame(minWidth: macOSWindowSize().minWidth, minHeight: macOSWindowSize().minHeight)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        macOSContentView()
    }
}
