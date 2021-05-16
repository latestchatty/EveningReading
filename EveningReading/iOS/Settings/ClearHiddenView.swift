//
//  ClearHiddenView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/9/21.
//

import SwiftUI

struct ClearHiddenView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    @State private var showingClearHiddenAlert = false
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                self.showingClearHiddenAlert = true
            }) {
                Text("Clear Hidden")
                    .foregroundColor(Color(UIColor.link))
            }
            .buttonStyle(DefaultButtonStyle())
            .alert(isPresented: self.$showingClearHiddenAlert) {
                Alert(title: Text("Clear Hidden?"), message: Text(""), primaryButton: .destructive(Text("Yes")) {
                    appSessionStore.collapsedThreads.removeAll()
                    appSessionStore.blockedAuthors.removeAll()
                }, secondaryButton: .cancel() {
                    
                })
            }
            Spacer()
        }
    }
}


struct ClearHiddenView_Previews: PreviewProvider {
    static var previews: some View {
        ClearHiddenView()
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
