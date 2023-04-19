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
    
    @StateObject var context = TextContext()
    
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
                            
                            ShackTagsTextView(text: $postBody, disabled: $chatStore.showingNewPostSpinner, textContext: context)
                                .border(Color(NSColor.systemGray))
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                            
                            VStack {
                                HStack {
                                    Button(action: {
                                        context.isRed.toggle()
                                    }) {
                                        Text("Red")
                                            .frame(minWidth: 45)
                                            .foregroundColor(Color(NSColor.systemRed))
                                    }
                                    Button(action: {
                                        context.isGreen.toggle()
                                    }) {
                                        Text("Green")
                                            .frame(minWidth: 45)
                                            .foregroundColor(Color(NSColor.systemGreen))
                                    }
                                    Button(action: {
                                        context.isBlue.toggle()
                                    }) {
                                        Text("Blue")
                                            .frame(minWidth: 45)
                                            .foregroundColor(Color(NSColor.systemBlue))
                                    }
                                    Button(action: {
                                        context.isYellow.toggle()
                                    }) {
                                        Text("Yellow")
                                            .frame(minWidth: 45)
                                            .foregroundColor(Color("YellowText"))
                                    }
                                    Button(action: {
                                        context.isLime.toggle()
                                    }) {
                                        Text("Lime")
                                            .frame(minWidth: 45)
                                            .foregroundColor(Color("LimeText"))
                                    }
                                    Button(action: {
                                        context.isOrange.toggle()
                                    }) {
                                        Text("Orange")
                                            .frame(minWidth: 45)
                                            .foregroundColor(Color(NSColor.systemOrange))
                                    }
                                    Button(action: {
                                        context.isPink.toggle()
                                    }) {
                                        Text("Pink")
                                            .frame(minWidth: 45)
                                            .foregroundColor(Color("PinkText"))
                                    }
                                    Button(action: {
                                        context.isOlive.toggle()
                                    }) {
                                        Text("Olive")
                                            .frame(minWidth: 45)
                                            .foregroundColor(Color("OliveText"))
                                    }
                                }
                                HStack {
                                    Button(action: {
                                        context.isItalic.toggle()
                                    }) {
                                        Text("Italic")
                                            .italic()
                                            .frame(minWidth: 45)
                                    }
                                    Button(action: {
                                        context.isBold.toggle()
                                    }) {
                                        Text("Bold")
                                            .bold()
                                            .frame(minWidth: 45)
                                    }
                                    Button(action: {
                                        context.isUnderline.toggle()
                                    }) {
                                        Text("Under")
                                            .frame(minWidth: 45)
                                    }
                                    Button(action: {
                                        context.isQuote.toggle()
                                    }) {
                                        Text("Quote")
                                            .frame(minWidth: 45)
                                    }
                                    Button(action: {
                                        context.isCode.toggle()
                                    }) {
                                        Text("Code")
                                            .frame(minWidth: 45)
                                    }
                                    Button(action: {
                                        context.isSample.toggle()
                                    }) {
                                        Text("Sample")
                                            .frame(minWidth: 45)
                                    }
                                    Button(action: {
                                        context.isStrike.toggle()
                                    }) {
                                        Text("Strike")
                                            .strikethrough()
                                            .frame(minWidth: 45)
                                    }
                                    Button(action: {
                                        context.isSpoiler.toggle()
                                    }) {
                                        Text("Spoiler")
                                            .frame(minWidth: 45)
                                    }
                                }
                            }
                            
                            /*
                            TextEditor(text: self.$postBody)
                                .border(Color(NSColor.systemGray))
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                            */
                            
                            Button(action: {
                                //print("log: text is \(postBody)")
                                showingSubmitAlert = true
                            }) {
                                Text("Submit")
                                    .frame(minWidth: 180)
                            }
                            .padding(.vertical)
                            .disabled(postBody.count < 5)
                            .alert(isPresented: self.$showingSubmitAlert) {
                                Alert(title: Text("Submit Post?"), message: Text(""), primaryButton: .destructive(Text("Yes")) {
                                    self.chatStore.submitPost(postBody: self.postBody, postId: chatStore.newPostParentId)
                                    if chatStore.newPostParentId == 0 {
                                        chatStore.activeThreadId = 0
                                        chatStore.activePostId = 0
                                        chatStore.postingNewThread = true
                                    }
                                    chatStore.showingNewPostSheet = false
                                    chatStore.showingNewPostSpinner = true
                                    postBody = ""
                                }, secondaryButton: .cancel() {
                                    
                                })
                            }
                            
                        }
                    }
                }
        }
    }
}
