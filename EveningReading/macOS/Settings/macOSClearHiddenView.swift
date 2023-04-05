//
//  macOSClearHiddenView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/8/21.
//

import SwiftUI

struct macOSClearHiddenView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    @State private var showingClearHiddenThreadsAlert = false
    @State private var showingClearBlockedUsersAlert = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                self.showingClearHiddenThreadsAlert = true
            }) {
                Text("Clear Hidden Threads")
                    .frame(minWidth: 180)
            }
            .alert(isPresented: self.$showingClearHiddenThreadsAlert) {
                Alert(title: Text("Clear Hidden Threads?"), message: Text(""), primaryButton: .destructive(Text("Yes")) {
                    appSessionStore.collapsedThreads.removeAll()
                }, secondaryButton: .cancel() {
                    
                })
            }
            Button(action: {
                self.showingClearBlockedUsersAlert = true
            }) {
                Text("Clear Blocked Users")
                    .frame(minWidth: 180)
            }
            .alert(isPresented: self.$showingClearBlockedUsersAlert) {
                Alert(title: Text("Clear Blocked Users?"), message: Text(""), primaryButton: .destructive(Text("Yes")) {
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
