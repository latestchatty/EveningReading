//
//  macOSAccountView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/8/21.
//

import SwiftUI

struct macOSAccountView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var messageStore: MessageStore

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var showingSignIn = false
    @State private var showingSignOut = false
    
    private func showSignIn() {
        self.showingSignIn = true
    }
    
    private func cancelSignIn() {
        appSessionStore.signInUsername = ""
        appSessionStore.signInPassword = ""
        self.showingSignIn = false
    }

    private func signIn() {
        if self.appSessionStore.signInUsername.count < 1 || self.appSessionStore.signInPassword.count < 1 {
            self.appSessionStore.showingSignInWarning = true
        } else {
            self.appSessionStore.authenticate()
        }
    }
    
    private func showSignOut() {
        self.showingSignOut = true
    }
    
    private func closeAlert() {
        appSessionStore.showingSignInWarning = false
    }
    
    var body: some View {
        HStack {
            
            // Sign in/out button
            if self.appSessionStore.isSignedIn {
                Button(action: showSignOut) {
                    Text("Sign Out As \(appSessionStore.username)")
                }
            } else {
                Button(action: showSignIn) {
                    Text("Sign In").foregroundColor(Color.primary).bold()
                }
            }
            
            Spacer().frame(width:0, height: 0)
            
            // Sign In
            .sheet(isPresented: self.$showingSignIn) {
                ZStack {
                    VStack {
                        Text("Sign In").bold().font(.title)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        
                        TextField("Username", text: $appSessionStore.signInUsername)
                        .padding()
                        .textContentType(.username)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        .disabled(appSessionStore.showingSignInWarning)
                        
                        SecureField("Password", text: $appSessionStore.signInPassword) {
                        }
                        .padding()
                        .textContentType(.password)
                        .padding(.bottom, 10)
                        .disabled(appSessionStore.showingSignInWarning)
                        
                        HStack {
                            Button(action: cancelSignIn) {
                                Text("Cancel").foregroundColor(Color.primary).bold()
                            }
                            .disabled(appSessionStore.showingSignInWarning)
                            Button(action: signIn) {
                                Text("Sign In").foregroundColor(Color.primary).bold()
                            }
                            .disabled(appSessionStore.showingSignInWarning)
                        }
                    }
                    if appSessionStore.showingSignInWarning {
                        VStack {}
                        .frame(width: 240, height: 120)
                        .background(Color("macOSAlertBackground"))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 1))

                        VStack {
                            Text("Sign In Failed")
                            Text("Incorrect username or password.")
                            Button(action: closeAlert) {
                                Text("OK").foregroundColor(Color.primary).bold()
                            }
                        }
                        .cornerRadius(8)
                        .frame(width: 240, height: 120)
                    }
                }
                .frame(width: 320, height: 240)
            }
            
            // Sign Out
            .alert(isPresented: self.$showingSignOut) {
                Alert(title: Text("Sign Out?"), message: Text(""), primaryButton: .destructive(Text("Yes")) {
                    appSessionStore.isSignedIn = false
                    appSessionStore.username = ""
                    appSessionStore.password = ""
                    appSessionStore.clearNotifications()
                    messageStore.clearMessages()
                }, secondaryButton: .cancel() {
                    
                })
            }
            
            // Did sign in
            .onReceive(timer) { _ in
                if appSessionStore.isSignedIn {
                    self.timer.upstream.connect().cancel()
                    self.showingSignIn = false
                }
            }
            
            Spacer()
        }
    }
}

struct macOSAccountView_Previews: PreviewProvider {
    static var previews: some View {
        macOSAccountView()
            .environment(\.colorScheme, .dark)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(MessageStore(service: MessageService()))
    }
}
