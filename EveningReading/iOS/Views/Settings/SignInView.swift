//
//  SignInView.swift
//  iOS
//
//  Created by Chris Hodge on 8/14/20.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appService: AppService
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private func signIn() {
        if appService.signInUsername.count < 1 || appService.signInPassword.count < 1 {
            appService.showingSignInWarning = true
        } else {
            appService.authenticate()
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
                    
                    TextField("Username", text: $appService.signInUsername)
                        .padding()
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .background(Color("SignInField"))
                        .cornerRadius(4.0)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                        
                    SecureField("Password", text: $appService.signInPassword) {
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
                
                .alert(isPresented: $appService.showingSignInWarning) {
                    Alert(title: Text("Sign In Failed"), message: Text("Incorrect username or password."), dismissButton: .default(Text("Okay")))
                }
                
            }
            .padding()
            .background(Color("SignInBackground").frame(height: BackgroundHeight).offset(y: BackgroundOffset))
            .disabled(appService.isAuthenticating)
            .overlay(AuthenticatingView(isVisible: $appService.isAuthenticating))
            .onReceive(timer) { _ in
                if appService.isSignedIn {
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
