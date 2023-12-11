//
//  macOSTagPostView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/10/21.
//

import Foundation

import SwiftUI

struct macOSTagPostView: View {
    @EnvironmentObject var appService: AppService
    
    var body: some View {
        if appService.isSignedIn {
            Image(systemName: "tag")
                .imageScale(.large)
                .onTapGesture(count: 1) {
                }
        } else {
            EmptyView()
        }
    }
}
