//
//  macOSContentView.swift
//  Shared
//
//  Created by Chris Hodge on 4/28/21.
//

import SwiftUI

#if os(OSX)
struct macOSWindowSize {
    let minWidth : CGFloat = 800
    let minHeight : CGFloat = 600
}
#endif

struct macOSContentView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
        
    private func navigateTo(_ goToDestination: inout Bool) {
        appSessionStore.resetNavigation()
        goToDestination = true
    }
    
    var body: some View {
        HStack() {
            NavigationView {
                List {
                    Text("Evening Reading")
                        .font(.caption2)
                        .foregroundColor(Color("macOSSidebarHeader"))
                        .bold()                    
                    Group{
                        NavigationLink(destination: macOSChatView()) {
                            Label("Chat", systemImage: "text.bubble")
                        }
                        NavigationLink(destination: macOSInboxView()) {
                            Label("Inbox", systemImage: "envelope.open")
                        }
                        NavigationLink(destination: macOSSearchView()) {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        NavigationLink(destination: macOSTagsView()) {
                            Label("Tags", systemImage: "tag")
                        }
                        NavigationLink(destination: macOSSettingsView()) {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                .navigationTitle("Explore")
                .frame(minWidth: 150, idealWidth: 250, maxWidth: 300)
                .toolbar{
                    //Toggle Sidebar Button
                    ToolbarItem(placement: .navigation){
                        Button(action: {
                            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                        }, label: {
                            Image(systemName: "sidebar.left")
                        })
                    }
                }
                
                //Default View on Mac
                macOSChatView()
            }
        }
        .frame(minWidth: macOSWindowSize().minWidth, minHeight: macOSWindowSize().minHeight)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct macOSContentView_Previews: PreviewProvider {
    static var previews: some View {
        macOSContentView()
            .environmentObject(AppSessionStore())
    }
}
