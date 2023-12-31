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
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService
        
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
                        if appService.showingChatView {
                            Button(action: {
                                // refresh
                                chatService.activeThreadId = 0
                                chatService.activePostId = 0
                                chatService.newPostParentId = 0
                                chatService.getChat()
                            }, label: {
                                Image(systemName: "arrow.counterclockwise")
                            })
                            if appService.isSignedIn {
                                Button(action: {
                                    // compose
                                    chatService.newPostParentId = 0
                                    chatService.showingNewPostSheet = true
                                }, label: {
                                    Image(systemName: "square.and.pencil")
                                })
                                .keyboardShortcut("n", modifiers: [.command])
                            }
                            Button(action: {
                                // refresh
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                                    chatService.activeThreadId = 0
                                    chatService.activePostId = 0
                                    chatService.newPostParentId = 0
                                    chatService.getChat()
                                }
                            }, label: {
                                Spacer().frame(width: 0)
                            })
                            .keyboardShortcut("r", modifiers: [.command])
                        } else if appService.showingInboxView {
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
                if appService.showingChatView {
                    macOSChatView()
                } else if appService.showingInboxView {
                    macOSInboxView()
                } else if appService.showingSearchView {
                    macOSSearchView()
                } else if appService.showingTagsView {
                    macOSTagsView()
                } else if appService.showingSettingsView {
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
            appService.showingChatView = true
        }
    }
}
