//
//  macOSNewPostView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 4/5/23.
//

import SwiftUI

struct macOSComposePostView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    @State private var postBody = ""
    @State private var showingSubmitAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            Text("")
                .sheet(isPresented: $chatStore.showingNewPostSheet) {
                    ZStack {
                        VStack {}.frame(width: 800, height: 450)
                        VStack {
                            HStack {
                                Button(action: {
                                    chatStore.showingNewPostSheet = false
                                    postBody = ""
                                }) {
                                    Image(systemName: "xmark")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .padding()
                                .keyboardShortcut(.cancelAction)
                                
                                Text(chatStore.newPostParentId != 0 ? "Replying to \(chatStore.newReplyAuthorName)" : "New Thread")
                                    .bold()
                                    .font(.body)
                                Spacer()
                            }
                            
                            TextEditor(text: self.$postBody)
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
                            .disabled(postBody.count < 5)
                            .alert(isPresented: self.$showingSubmitAlert) {
                                Alert(title: Text("Submit Post?"), message: Text(""), primaryButton: .destructive(Text("Yes")) {
                                    postBody = ""
                                    if chatStore.newPostParentId == 0 {
                                        chatStore.activeThreadId = 0
                                        chatStore.activePostId = 0
                                        chatStore.postingNewThread = true
                                    }
                                    chatStore.showingNewPostSheet = false
                                    chatStore.showingNewPostSpinner = true
                                }, secondaryButton: .cancel() {
                                    
                                })
                            }
                            
                        }
                    }
                }
        }
    }
}
