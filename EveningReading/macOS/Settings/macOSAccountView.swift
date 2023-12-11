//
//  macOSAccountView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/8/21.
//

import SwiftUI

struct macOSAccountView: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService
    
    @StateObject var messageViewModel = MessageViewModel()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var showingSignIn = false
    @State private var showingSignOut = false
    
    private func showSignIn() {
        self.showingSignIn = true
    }
    
    private func cancelSignIn() {
        appService.signInUsername = ""
        appService.signInPassword = ""
        self.showingSignIn = false
    }

    private func signIn() {
        if self.appService.signInUsername.count < 1 || self.appService.signInPassword.count < 1 {
            self.appService.showingSignInWarning = true
        } else {
            self.appService.authenticate()
        }
    }
    
    private func showSignOut() {
        self.showingSignOut = true
    }
    
    private func closeAlert() {
        appService.showingSignInWarning = false
    }
    
    var body: some View {
        HStack {
            
            // Sign in/out button
            VStack (alignment: .center) {
                if self.appService.isSignedIn {
                    Text("Signed In As: ") + Text("\(appService.username)").foregroundColor(Color(NSColor.systemBlue))
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
                        
                        TextField("Username", text: $appService.signInUsername)
                        .padding()
                        .textContentType(.username)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        .disabled(appService.showingSignInWarning)
                        
                        SecureField("Password", text: $appService.signInPassword) {
                        }
                        .padding()
                        .textContentType(.password)
                        .padding(.bottom, 10)
                        .disabled(appService.showingSignInWarning)
                        
                        HStack {
                            Button(action: cancelSignIn) {
                                Text("Cancel").foregroundColor(Color.primary).bold()
                            }
                            .disabled(appService.showingSignInWarning)
                            Button(action: signIn) {
                                Text("Sign In").foregroundColor(Color.primary).bold()
                            }
                            .disabled(appService.showingSignInWarning)
                            .keyboardShortcut(.defaultAction)
                        }
                    }
                    if appService.showingSignInWarning {
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
                    appService.isSignedIn = false
                    appService.username = ""
                    appService.password = ""
                    appService.clearNotifications()
                    messageViewModel.clearMessages()
                    chatService.newPostParentId = 0
                }, secondaryButton: .cancel() {
                    
                })
            }
            
            // Did sign in
            .onReceive(timer) { _ in
                if appService.isSignedIn {
                    self.timer.upstream.connect().cancel()
                    self.showingSignIn = false
                }
            }
            
            Spacer()
        }
    }
}
