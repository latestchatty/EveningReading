//
//  iPadContentView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 4/30/21.
//

import SwiftUI

struct iPadContentView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    var body: some View {
        Text("Evening Reading iPadOS")
    }
}

struct iPadContentView_Previews: PreviewProvider {
    static var previews: some View {
        iPadContentView()
    }
}
