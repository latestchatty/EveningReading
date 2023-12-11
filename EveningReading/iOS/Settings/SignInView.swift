//
//  SignInView.swift
//  iOS
//
//  Created by Chris Hodge on 8/14/20.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSession: AppSession
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private func signIn() {
        if self.appSession.signInUsername.count < 1 || self.appSession.signInPassword.count < 1 {
            self.appSession.showingSignInWarning = true
        } else {
            self.appSession.authenticate()
        }
    }

    private func close() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }

    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Image("appicon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 74.0)
                        .cornerRadius(9)
                    
                    Text("Sign In").bold().font(.title)
                    Text("Lamp, Sand, Lime.").font(.subheadline)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 70, trailing: 0))
                    
                    TextField("Username", text: $appSession.signInUsername)
                        .padding()
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .background(Color("SignInField"))
                        .cornerRadius(4.0)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                        
                    SecureField("Password", text: $appSession.signInPassword) {
                    }
                    .padding()
                    .textContentType(.password)
                    .background(Color("SignInField"))
                    .cornerRadius(4.0)
                    .padding(.bottom, 10)
                    
                    HStack() {
                        Spacer()
                        Link("Guidelines", destination: URL(string: "https://www.shacknews.com/guidelines")!).font(.callout).foregroundColor(Color.primary)
                    }.padding(.bottom, 40)
                   
                    Button(action: signIn) {
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Sign In").foregroundColor(Color.primary).bold()
                            Spacer()
                        }
                    }.padding().background(Color("SignInButton")).cornerRadius(4.0)
                }
                .padding()
                
                .alert(isPresented: $appSession.showingSignInWarning) {
                    Alert(title: Text("Sign In Failed"), message: Text("Incorrect username or password."), dismissButton: .default(Text("Okay")))
                }
                
            }
            .padding()
            .background(Color("SignInBackground").frame(height: 2600).offset(y: -80))
            .disabled(appSession.isAuthenticating)
            .overlay(AuthenticatingView(isVisible: $appSession.isAuthenticating))
            .onReceive(timer) { _ in
                if appSession.isSignedIn {
                    self.timer.upstream.connect().cancel()
                    NotificationStore(service: .init()).register()
                    NotificationStore(service: .init()).registernew()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: close) {
                        Image(systemName: "clear.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32.0)
                            .foregroundColor(Color("SignInCloseButton"))
                    }
                }
                Spacer()
            }
            .padding()

        }
    }
}
