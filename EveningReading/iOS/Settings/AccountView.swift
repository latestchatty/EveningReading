//
//  AccountView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/7/21.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore


    @State private var showingSignIn = false
    @State private var showingSignOut = false
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                if self.appSessionStore.isSignedIn {
                    self.showingSignOut = true
                } else {
                    self.showingSignIn = true
                }
            }) {
                if self.appSessionStore.isSignedIn {
                    Text("Sign Out")
                        .foregroundColor(Color(UIColor.link))
                } else {
                    Text("Sign In")
                        .foregroundColor(Color(UIColor.link))
                }
            }
            .buttonStyle(DefaultButtonStyle())
            .fullScreenCover(isPresented: self.$showingSignIn, content: SignInView.init)
            .alert(isPresented: self.$showingSignOut) {
                Alert(title: Text("Sign Out?"), message: Text(""), primaryButton: .destructive(Text("Yes")) {
                    self.appSessionStore.isSignedIn = false
                }, secondaryButton: .cancel() {
                    
                })
            }
            Spacer()
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
