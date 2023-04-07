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
    @EnvironmentObject var messageStore: MessageStore
    
    @State private var messageBody = ""
    @State private var showingSubmitAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            Text("")
                .sheet(isPresented: $messageStore.showingReportUserSheet) {
                    ZStack {
                        VStack {}.frame(width: 800, height: 450)
                        .onAppear() {
                            messageBody = messageStore.getComplaintText(author: messageStore.reportAuthorName, postId: messageStore.reportAuthorForPostId)
                        }
                        VStack {
                            HStack {
                                Button(action: {
                                    messageStore.showingReportUserSheet = false
                                    messageBody = ""
                                }) {
                                    Image(systemName: "xmark")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .padding()
                                .keyboardShortcut(.cancelAction)
                                
                                Text("Report user \(messageStore.reportAuthorName)")
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
                                    messageStore.submitComplaint(author: messageStore.reportAuthorName, postId: 0)
                                    messageStore.showingReportUserSheet = false
                                    messageBody = ""
                                    messageStore.reportAuthorForPostId = 0
                                    messageStore.reportAuthorName = ""
                                }, secondaryButton: .cancel() {
                                    
                                })
                            }
                            
                        }
                    }
                }
        }
    }
}
