//
//  GoToPostView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/10/21.
//

import SwiftUI

struct GoToPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var notifications: Notifications
    @EnvironmentObject var chatStore: ChatStore
    
    @State private var goToPostId: Int = 0
    @State private var showingPost: Bool = false
    @State private var showingAlert: Bool = false
        
    var isHomeView = false
    var currentViewName = ""
    
    var body: some View {
        VStack {
            //Text("\(appSessionStore.showingPostId)")
            //Text("\(self.goToPostId) \(self.showingPost.description)")
            /*
            Button(action: {
                print("self.goToPostId = \(self.goToPostId)")
            }) {
                Text("What Id?")
            }
            */
            /*
            Text("\(appSessionStore.showingPostId)")
            Button(action: {
                self.goToPostId = appSessionStore.showingPostId
                self.showingPost = true
            }) {
                Text("Show Post")
            }
            */
            
            // Fixes navigation bug
            // https://developer.apple.com/forums/thread/677333
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.hidden().disabled(true).allowsHitTesting(false)
            
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) {
                EmptyView()
            }.hidden().disabled(true).allowsHitTesting(false)
            
            /*
            // Deep link to specific shack post
            .onChange(of: appSessionStore.showingShackLink, perform: { value in
                print(".onReceive(appSessionStore.$showingShackLink)")
                if value {
                    print("going to try to show link")
                    if appSessionStore.shackLinkPostId != "" {
                        print("showing link")
                        self.appSessionStore.showingShackLink = false
                        self.goToPostId = Int(appSessionStore.shackLinkPostId) ?? 0
                        appSessionStore.showingPostId = Int(appSessionStore.shackLinkPostId) ?? 0
                        self.showingPost = true
                    }
                }
            })
            */
            /*
            .onReceive(appSessionStore.$showingShackLink) { value in
                print(".onReceive(appSessionStore.$showingShackLink)")
                if value {
                    print("going to try to show link")
                    if appSessionStore.shackLinkPostId != "" {
                        print("showing link")
                        self.appSessionStore.showingShackLink = false
                        self.goToPostId = Int(appSessionStore.shackLinkPostId) ?? 0
                        self.showingPost = true
                    }
                }
            }
            */
            
            // Push ThreadDetailView
            NavigationLink(destination: ThreadDetailView(threadId: .constant(0), postId: $appSessionStore.showingPostId, replyCount: .constant(-1), isSearchResult: .constant(true)), isActive: self.$showingPost) {
                EmptyView()
            }.isDetailLink(false).hidden().allowsHitTesting(false)
            
            /*
            NavigationLink(destination: ThreadDetailView(threadId: .constant(0), postId: $appSessionStore.showingPostId, replyCount: .constant(-1), isSearchResult: .constant(true)), isActive: $appSessionStore.showingPostWithId[appSessionStore.showingPostId].unwrap() ?? .constant(false)) {
                EmptyView()
            }.isDetailLink(false).hidden().allowsHitTesting(false)
            */
            
            /*
            NavigationLink(destination: ThreadDetailView(threadId: .constant(0), postId: $appSessionStore.showingPostId, replyCount: .constant(-1), isSearchResult: .constant(true)), tag: "GoToPost", selection: self.$selection) {
                EmptyView()
            }.isDetailLink(false).hidden().allowsHitTesting(false)
            */
            
            /*
            .onChange(of: notifications.notificationData, perform: { value in
                print(".onReceive(notifications.$notificationData)")
                if let postId = value?.notification.request.content.userInfo["postid"] {
                    print("got postId \(postId), previously showed \(appSessionStore.showingPostId)")
                    if String("\(postId)").isInt && appSessionStore.showingPostId != Int(String("\(postId)")) ?? 0 {
                        print("setting postID \(postId)")
                        appSessionStore.showingPostId = Int(String("\(postId)")) ?? 0
                        DispatchQueue.main.async {
                            print("post id is really \(Int(String("\(postId)")) ?? 0)")
                            notifications.notificationData = nil
                            self.goToPostId = Int(String("\(postId)")) ?? 0
                            self.showingPost = true
                            //self.showingAlert = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                            print("going to post \(postId)")
                            self.showingPost = true
                        }
                    }
                }
            })
            */
            
            /*
            .onChange(of: appSessionStore.showingPostId, perform: { value in
                if value != 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                        self.showingPost = true
                    }
                }
            })
            */
            
            /*
            .onAppear() {
                DispatchQueue.main.async {
                    notifications.notificationData.publisher.sink { value in
                        let postId = value.notification.request.content.userInfo["postid"]!
                        let body = value.notification.request.content.body
                        let title = value.notification.request.content.title
                        
                        print("got postId \(postId), previously showed \(appSessionStore.showingPostId)")
                        if String("\(postId)").isInt && appSessionStore.showingPostId != Int(String("\(postId)")) ?? 0 {
                            
                            notifications.notificationData = nil
                            print("setting postID \(postId)")
                            appSessionStore.showingPostId = Int(String("\(postId)")) ?? 0
                            print("going to post \(Int(String("\(postId)")) ?? 0)")
                            self.goToPostId = Int(String("\(postId)")) ?? 0
                            print("self.goToPostId = \(self.goToPostId)")
                            
                            appSessionStore.pushNotifications.append(PushNotification(title: title, body: body, postId: Int(String("\(postId)")) ?? 0))
                                                    
                            if !self.isHomeScreen {
                                appSessionStore.showingNotificationReceiveNotice = true
                            }
                            
                            self.showingPost = false
                            
                            DispatchQueue.main.async {
                                self.showingPost = true
                            }
                            
                        }
                    }
                }
            }
            */
            
            // Deep link to post from push notification
            .onReceive(notifications.$notificationData) { value in

                if let postId = value?.notification.request.content.userInfo["postid"], let body = value?.notification.request.content.body, let title = value?.notification.request.content.title {
                    //print("got postId \(postId), previously showed \(appSessionStore.showingPostId)")
                    if String("\(postId)").isInt && appSessionStore.showingPostId != Int(String("\(postId)")) ?? 0 {

                        notifications.notificationData = nil
                        //print("setting postID \(postId)")
                        appSessionStore.showingPostId = Int(String("\(postId)")) ?? 0
                        //print("going to post \(Int(String("\(postId)")) ?? 0)")
                        //self.goToPostId = Int(String("\(postId)")) ?? 0
                        print("showingPostId = \(appSessionStore.showingPostId)")
                                                
                        //appSessionStore.showingPostWithId[appSessionStore.showingPostId] = true
                        
                        //self.showingPost = true
                        
                        //self.showingAlert = true
                        //self.presentationMode.wrappedValue.dismiss()
                        appSessionStore.pushNotifications.append(PushNotification(title: title, body: body, postId: Int(String("\(postId)")) ?? 0))
                        
                        /*
                        if !self.isHomeScreen {
                            appSessionStore.showingNotificationReceiveNotice = true
                        }
                        */
                        
                        print("\(appSessionStore.currentViewName) == \(self.currentViewName)")
                        
                        //if appSessionStore.currentViewName == self.currentViewName {
                            appSessionStore.showingPost = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                                // go to home screen
                                appSessionStore.showingChatView = false
                            }
                        //}
                    }
                    /*
                    if !self.disabled && String("\(postId)").isInt {
                        self.disabled = true
                        self.notifications.notificationData = nil
                        self.goToPostId = Int(String("\(postId)")) ?? 0
                        self.showingPost = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                            self.disabled = false
                        }
                    }
                    */
                }
                /*
                print("got notification \(value)")
                if let notification = value?.notification.request.content.body {
                    print("got body \(body)")
                }
                */
            }
            
            
            /*
            .alert(isPresented: self.$showingAlert) {
                Alert(title: Text("Notification Received"), message: Text("PostId"),
                      primaryButton: .default (Text("OK")) {
                        DispatchQueue.main.async {
                            self.showingPost = true
                        }
                      }, secondaryButton: .cancel()
                )
            }
            */
            
        }
        .frame(width: 0, height: 0)
    }
}

struct GoToPostView_Previews: PreviewProvider {
    static var previews: some View {
        GoToPostView()
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(Notifications())
            .environmentObject(ChatStore(service: ChatService()))
    }
}
