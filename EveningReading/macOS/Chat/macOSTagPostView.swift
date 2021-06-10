//
//  macOSTagPostView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/10/21.
//

import Foundation

import SwiftUI

struct macOSTagPostView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    var body: some View {
        if appSessionStore.isSignedIn {
            Image(systemName: "tag")
                .imageScale(.large)
                .onTapGesture(count: 1) {
                }
        } else {
            EmptyView()
        }
    }
}

struct macOSTagPostView_Previews: PreviewProvider {
    static var previews: some View {
        macOSTagPostView()
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
