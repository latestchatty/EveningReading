//
//  macOSPostActionsView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 4/9/23.
//

import SwiftUI

enum PostActionAlertTypes {
    case hideThread
    case blockUser
}

struct macOSPostActionsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore

    @StateObject var messageViewModel = MessageViewModel()
    
    var name: String = ""
    var postId: Int = 0
    var showingHideThread = false
    
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var alertSubtitle = ""
    @State var alertAction = PostActionAlertTypes.hideThread
    
    var body: some View {
        Menu {
            if showingHideThread {
                Button(action: {
                    self.alertTitle = "Hide thread?"
                    self.alertSubtitle = ""
                    self.showingAlert = true
                    self.alertAction = PostActionAlertTypes.hideThread
                }) {
                    Text("Hide Thread")
                    Image(systemName: "eye.slash")
                }
            }
            Button(action: {
                messageViewModel.reportAuthorName = self.name
                messageViewModel.showingReportUserSheet = true
                messageViewModel.reportAuthorForPostId = self.postId
            }) {
                Text("Report User")
                Image(systemName: "exclamationmark.circle")
            }
            Button(action: {
                self.alertTitle = "Block \(self.name)?"
                self.alertSubtitle = "For post \(String(self.postId))"
                self.showingAlert = true
                self.alertAction = PostActionAlertTypes.blockUser
            }) {
                Text("Block User")
                Image(systemName: "exclamationmark.circle")
            }
        } label: {
            Image(systemName: "ellipsis")
                .imageScale(.large)
        }
        .menuStyle(BorderlessButtonMenuStyle(showsMenuIndicator: false))
        .fixedSize()
        .help("Actions")
        .alert(isPresented: self.$showingAlert) {
            Alert(title: Text(self.alertTitle), message: Text(self.alertSubtitle), primaryButton: .default(Text("Yes")) {
                
                switch alertAction {
                case .hideThread:
                    // collapse thread
                    appSessionStore.collapsedThreads.append(self.postId)
                    chatStore.activeThreadId = 0
                    chatStore.getThread()
                case .blockUser:
                    // block user
                    appSessionStore.blockedAuthors.append(self.name)
                }
            }, secondaryButton: .cancel() {
                
            })
        }
    }
}
