//
//  macOSReportUserView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 4/7/23.
//

import SwiftUI

struct macOSReportUserView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSession: AppSession
    @EnvironmentObject var chatStore: ChatStore

    @StateObject var messageViewModel = MessageViewModel()
    
    @State private var messageBody = ""
    @State private var showingSubmitAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            Text("")
                .sheet(isPresented: $appSession.showingReportUserSheet) {
                    ZStack {
                        VStack {}.frame(width: 800, height: 450)
                        .onAppear() {
                            messageBody = messageViewModel.getComplaintText(author: appSession.reportAuthorName, postId: appSession.reportAuthorForPostId)
                        }
                        VStack {
                            HStack {
                                Button(action: {
                                    appSession.showingReportUserSheet = false
                                    messageBody = ""
                                }) {
                                    Image(systemName: "xmark")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .padding()
                                .keyboardShortcut(.cancelAction)
                                
                                Text("Report \(appSession.reportAuthorName)")
                                    .bold()
                                    .font(.body)
                                Spacer()
                            }
                            
                            TextEditor(text: self.$messageBody)
                                .border(Color(NSColor.systemGray))
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                            
                            Button(action: {
                                showingSubmitAlert = true
                            }) {
                                Text("Submit")
                                    .frame(minWidth: 180)
                            }
                            .padding(.vertical)
                            .alert(isPresented: self.$showingSubmitAlert) {
                                Alert(title: Text("Report User?"), message: Text(""), primaryButton: .destructive(Text("Yes")) {
                                    messageViewModel.submitComplaint(author: appSession.reportAuthorName, postId: 0)
                                    appSession.showingReportUserSheet = false
                                    messageBody = ""
                                    appSession.reportAuthorForPostId = 0
                                    appSession.reportAuthorName = ""
                                }, secondaryButton: .cancel() {
                                    
                                })
                            }
                            
                        }
                    }
                }
        }
    }
}
