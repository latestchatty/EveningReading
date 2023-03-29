//
//  ClearHiddenView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/9/21.
//

import SwiftUI

struct ClearBlockedView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    @State private var showingClearBlockedAlert = false
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                self.showingClearBlockedAlert = true
            }) {
                Text("Clear Blocked Users")
                    .foregroundColor(Color(UIColor.link))
            }
            .buttonStyle(DefaultButtonStyle())
            .alert(isPresented: self.$showingClearBlockedAlert) {
                Alert(title: Text("Clear Blocked Users?"), message: Text(""), primaryButton: .destructive(Text("Yes")) {
                    appSessionStore.blockedAuthors.removeAll()
                }, secondaryButton: .cancel() {
                    
                })
            }
            Spacer()
        }
    }
}


struct ClearBlockedView_Previews: PreviewProvider {
    static var previews: some View {
        ClearBlockedView()
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
