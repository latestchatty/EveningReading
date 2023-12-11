//
//  macOSGeneralView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 4/10/23.
//

import SwiftUI

struct macOSGeneralView: View {
    @EnvironmentObject var appService: AppService
    
    var body: some View {
        Group {
            Toggle(isOn: self.$appService.isDarkMode) {
                Text("Dark Mode")
            }
        }
    }
}
