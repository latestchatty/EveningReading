//
//  macOSReportUserView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 4/7/23.
//

import SwiftUI

struct macOSReportUserView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore

    @StateObject var messageViewModel = MessageViewModel()
    
    @State private var messageBody = ""
    @State private var showingSubmitAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            Text("")
                .sheet(isPresented: $messageViewModel.showingReportUserSheet) {
                    ZStack {
                        VStack {}.frame(width: 800, height: 450)
                        .onAppear() {
                            messageBody = messageViewModel.getComplaintText(author: messageViewModel.reportAuthorName, postId: messageViewModel.reportAuthorForPostId)
                        }
                        VStack {
                            HStack {
                                Button(action: {
                                    messageViewModel.showingReportUserSheet = false
                                    messageBody = ""
                                }) {
                                    Image(systemName: "xmark")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .padding()
                                .keyboardShortcut(.cancelAction)
                                
                                Text("Report \(messageViewModel.reportAuthorName)")
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
                                    messageViewModel.submitComplaint(author: messageViewModel.reportAuthorName, postId: 0)
                                    messageViewModel.showingReportUserSheet = false
                                    messageBody = ""
                                    messageViewModel.reportAuthorForPostId = 0
                                    messageViewModel.reportAuthorName = ""
                                }, secondaryButton: .cancel() {
                                    
                                })
                            }
                            
                        }
                    }
                }
        }
    }
}
