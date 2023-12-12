//
//  ClearHiddenView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/9/21.
//

import SwiftUI

struct ClearBlockedView: View {
    @EnvironmentObject var appService: AppService
    
    @State private var showingClearBlockedAlert = false
    
    var body: some View {
        HStack {
            Button(action: {
                self.showingClearBlockedAlert = true
            }) {
                Text("Clear Blocked Users")
                    .foregroundColor(Color(UIColor.link))
            }
            .buttonStyle(DefaultButtonStyle())
            .alert(isPresented: self.$showingClearBlockedAlert) {
                Alert(title: Text("Clear Blocked Users?"), message: Text(""), primaryButton: .destructive(Text("Yes")) {
                    appService.blockedAuthors.removeAll()
                }, secondaryButton: .cancel() {
                    
                })
            }
            Spacer()
        }
    }
}
