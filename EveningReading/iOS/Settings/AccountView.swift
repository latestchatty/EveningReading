//
//  AccountView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/7/21.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var messageStore: MessageStore

    @State private var showingSignIn = false
    @State private var showingSignOut = false
    
    private func user() -> String {
        let username: String? = KeychainWrapper.standard.string(forKey: "Username")
        return username ?? ""
    }
    
    var body: some View {
        HStack {
            //Spacer()
            
            // Sign in/out button
            Button(action: {
                if self.appSessionStore.isSignedIn {
                    self.showingSignOut = true
                } else {
                    self.showingSignIn = true
                }
            }) {
                if self.appSessionStore.isSignedIn {
                    Text("Sign Out As \(user())")
                        .foregroundColor(Color(UIColor.link))
                } else {
                    Text("Sign In")
                        .foregroundColor(Color(UIColor.link))
                }
            }
            .buttonStyle(DefaultButtonStyle())
            
            // Sign In
            .fullScreenCover(isPresented: self.$showingSignIn, content: SignInView.init)
            
            // Sign Out?
            .alert(isPresented: self.$showingSignOut) {
                Alert(title: Text("Sign Out?"), message: Text(""), primaryButton: .destructive(Text("Yes")) {
                    appSessionStore.isSignedIn = false
                    _ = KeychainWrapper.standard.removeObject(forKey: "Username")
                    _ = KeychainWrapper.standard.removeObject(forKey: "Password")
                    appSessionStore.clearNotifications()
                    messageStore.clearMessages()
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }, secondaryButton: .cancel() {
                    
                })
            }
            
            //Spacer()
        }
    }
}
