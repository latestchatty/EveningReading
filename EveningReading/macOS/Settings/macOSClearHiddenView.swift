//
//  macOSClearHiddenView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/8/21.
//

import SwiftUI

struct macOSClearHiddenView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    @State private var showingClearHiddenAlert = false
    
    var body: some View {
        HStack {
            Button(action: {
                self.showingClearHiddenAlert = true
            }) {
                Text("Clear Hidden")
            }
            .alert(isPresented: self.$showingClearHiddenAlert) {
                Alert(title: Text("Clear Hidden?"), message: Text(""), primaryButton: .destructive(Text("Yes")) {
                    appSessionStore.collapsedThreads.removeAll()
                    appSessionStore.blockedAuthors.removeAll()
                }, secondaryButton: .cancel() {
                    
                })
            }
        }
    }
}


struct macOSClearHiddenView_Previews: PreviewProvider {
    static var previews: some View {
        macOSClearHiddenView()
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
