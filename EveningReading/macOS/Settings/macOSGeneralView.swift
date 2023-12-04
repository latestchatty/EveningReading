//
//  macOSGeneralView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 4/10/23.
//

import SwiftUI

struct macOSGeneralView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    var body: some View {
        Group {
            Toggle(isOn: self.$appSessionStore.isDarkMode) {
                Text("Dark Mode")
            }
        }
    }
}
