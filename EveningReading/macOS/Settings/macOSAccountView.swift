//
//  macOSAccountView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/8/21.
//

import SwiftUI

struct macOSAccountView: View {
    @EnvironmentObject var appSession: AppSession
    @EnvironmentObject var chatStore: ChatStore
    
    @StateObject var messageViewModel = MessageViewModel()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var showingSignIn = false
    @State private var showingSignOut = false
    
    private func showSignIn() {
        self.showingSignIn = true
    }
    
    private func cancelSignIn() {
        appSession.signInUsername = ""
        appSession.signInPassword = ""
        self.showingSignIn = false
    }

    private func signIn() {
        if self.appSession.signInUsername.count < 1 || self.appSession.signInPassword.count < 1 {
            self.appSession.showingSignInWarning = true
        } else {
            self.appSession.authenticate()
        }
    }
    
    private func showSignOut() {
        self.showingSignOut = true
    }
    
    private func closeAlert() {
        appSession.showingSignInWarning = false
    }
    
    var body: some View {
        HStack {
            
            // Sign in/out button
            VStack (alignment: .center) {
                if self.appSession.isSignedIn {
                    Text("Signed In As: ") + Text("\(appSession.username)").foregroundColor(Color(NSColor.systemBlue))
                    Button(action: showSignOut) {
                        Text("Sign Out")
                            .frame(width: 200)
                    }
                } else {
                    Button(action: showSignIn) {
                        Text("")
                        Text("Sign In").foregroundColor(Color.primary).bold()
                            .frame(width: 200)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer().frame(width:0, height: 0)
            
            // Sign In
            .sheet(isPresented: self.$showingSignIn) {
                ZStack {
                    VStack {
                        Text("Sign In").bold().font(.title)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        
                        TextField("Username", text: $appSession.signInUsername)
                        .padding()
                        .textContentType(.username)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        .disabled(appSession.showingSignInWarning)
                        
                        SecureField("Password", text: $appSession.signInPassword) {
                        }
                        .padding()
                        .textContentType(.password)
                        .padding(.bottom, 10)
                        .disabled(appSession.showingSignInWarning)
                        
                        HStack {
                            Button(action: cancelSignIn) {
                                Text("Cancel").foregroundColor(Color.primary).bold()
                            }
                            .disabled(appSession.showingSignInWarning)
                            Button(action: signIn) {
                                Text("Sign In").foregroundColor(Color.primary).bold()
                            }
                            .disabled(appSession.showingSignInWarning)
                            .keyboardShortcut(.defaultAction)
                        }
                    }
                    if appSession.showingSignInWarning {
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
                    appSession.isSignedIn = false
                    appSession.username = ""
                    appSession.password = ""
                    appSession.clearNotifications()
                    messageViewModel.clearMessages()
                    chatStore.newPostParentId = 0
                }, secondaryButton: .cancel() {
                    
                })
            }
            
            // Did sign in
            .onReceive(timer) { _ in
                if appSession.isSignedIn {
                    self.timer.upstream.connect().cancel()
                    self.showingSignIn = false
                }
            }
            
            Spacer()
        }
    }
}
