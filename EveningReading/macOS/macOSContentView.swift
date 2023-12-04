//
//  macOSContentView.swift
//  Shared
//
//  Created by Chris Hodge on 4/28/21.
//

import SwiftUI

struct macOSWindowSize {
    let minWidth : CGFloat = 1280 // 1024
    let minHeight : CGFloat = 748 // 768
}

struct macOSContentView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var articleStore: ArticleStore
    @EnvironmentObject var messageStore: MessageStore
        
    @State private var showingChatView = false
    
    var body: some View {
        HStack() {
            NavigationView {
                
                // Navigation
                List {
                    Text("Evening Reading")
                        .font(.caption2)
                        .foregroundColor(Color("macOSSidebarHeader"))
                        .bold()
                    SidebarButtons()
                }
                .listStyle(SidebarListStyle())
                .navigationTitle("Evening Reading")
                .frame(minWidth: 150, idealWidth: 250, maxWidth: 300)
                .toolbar {
                    // Collapse Sidebar
                    ToolbarItem(placement: .automatic) {
                        Button(action: {
                            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                        }, label: {
                            Image(systemName: "sidebar.left")
                        })
                    }
                    
                    // Toolbar Buttons
                    ToolbarItemGroup(placement: .navigation) {
                        if appSessionStore.showingChatView {
                            Button(action: {
                                // refresh
                                chatStore.activeThreadId = 0
                                chatStore.activePostId = 0
                                chatStore.newPostParentId = 0
                                chatStore.getChat()
                            }, label: {
                                Image(systemName: "arrow.counterclockwise")
                            })
                            if appSessionStore.isSignedIn {
                                Button(action: {
                                    // compose
                                    chatStore.newPostParentId = 0
                                    chatStore.showingNewPostSheet = true
                                }, label: {
                                    Image(systemName: "square.and.pencil")
                                })
                                .keyboardShortcut("n", modifiers: [.command])
                            }
                            Button(action: {
                                // refresh
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                                    chatStore.activeThreadId = 0
                                    chatStore.activePostId = 0
                                    chatStore.newPostParentId = 0
                                    chatStore.getChat()
                                }
                            }, label: {
                                Spacer().frame(width: 0)
                            })
                            .keyboardShortcut("r", modifiers: [.command])
                        } else if appSessionStore.showingInboxView {
                            Button(action: {
                                // refresh
                            }, label: {
                                Image(systemName: "arrow.counterclockwise")
                            })
                            Button(action: {
                                // compose
                            }, label: {
                                Image(systemName: "square.and.pencil")
                            })
                        } else {
                            EmptyView()
                        }
                    }
                    
                }
                
                // Detail View
                if appSessionStore.showingChatView {
                    macOSChatView()
                        .environmentObject(messageStore)
                } else if appSessionStore.showingInboxView {
                    macOSInboxView()
                        .environmentObject(messageStore)
                } else if appSessionStore.showingSearchView {
                    macOSSearchView()
                } else if appSessionStore.showingTagsView {
                    macOSTagsView()
                } else if appSessionStore.showingSettingsView {
                    macOSSettingsView()
                } else {
                    EmptyView()
                }
            }
        }
        .background(Color("macOSPrimaryBackground"))
        .frame(minWidth: macOSWindowSize().minWidth, minHeight: macOSWindowSize().minHeight)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            appSessionStore.showingChatView = true
        }
    }
}

struct macOSContentView_Previews: PreviewProvider {
    static var previews: some View {
        macOSContentView()
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
            .environmentObject(ArticleStore(service: ArticleService()))
            .environmentObject(MessageStore(service: MessageService()))
    }
}
