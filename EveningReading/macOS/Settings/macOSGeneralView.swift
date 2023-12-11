//
//  macOSGeneralView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 4/10/23.
//

import SwiftUI

struct macOSGeneralView: View {
    @EnvironmentObject var appSession: AppSession
    
    var body: some View {
        Group {
            Toggle(isOn: self.$appSession.isDarkMode) {
                Text("Dark Mode")
            }
        }
    }
}
