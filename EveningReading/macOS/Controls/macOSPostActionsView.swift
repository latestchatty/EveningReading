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
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService

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
                appService.reportAuthorName = self.name
                appService.showingReportUserSheet = true
                appService.reportAuthorForPostId = self.postId
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
                    appService.collapsedThreads.append(self.postId)
                    chatService.activeThreadId = 0
                    chatService.getThread()
                case .blockUser:
                    // block user
                    appService.blockedAuthors.append(self.name)
                }
            }, secondaryButton: .cancel() {
                
            })
        }
    }
}
