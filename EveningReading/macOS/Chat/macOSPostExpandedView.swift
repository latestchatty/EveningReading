//
//  macOSPostExpandedView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/10/21.
//

import SwiftUI

struct macOSPostExpandedView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    @Binding var postId: Int
    @Binding var postAuthor: String
    @Binding var replyLines: String?
    @Binding var lols: [ChatLols]
    @Binding var postText: [RichTextBlock]
    @State var showReply = false
    @State var selectedTag: String = ""
    
    var body: some View {
        VStack {
            HStack {
                // Reply lines
                Text(self.replyLines == nil ? String(repeating: " ", count: 5) : self.replyLines!)
                    .lineLimit(1)
                    .fixedSize()
                    .font(.custom("replylines", size: 25, relativeTo: .callout))
                    .foregroundColor(Color("replyLines"))
                
                // Author
                AuthorNameView(name: self.postAuthor, postId: self.postId)
                
                Spacer()
                
                // Lols
                LolView(lols: self.lols, expanded: true, postId: self.postId)
                    .padding(.top, 5)
            }
            HStack {
                VStack (alignment: .leading) {
                    // Full post
                    RichTextView(topBlocks: self.postText)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if appSessionStore.isSignedIn {
                        VStack() {
                            HStack {
                                Spacer()
                              
                                TagPostButton(postId: self.postId)
                                Button(action: {
                                    showReply = !showReply
                                }, label: {
                                    Image(systemName: "arrowshape.turn.up.left")
                                        .imageScale(.large)
                                        .foregroundColor(showReply ? Color.accentColor : Color.primary)
                                })
                                .buttonStyle(BorderlessButtonStyle())
                                .help("Reply to post")
                                .keyboardShortcut("r", modifiers: [.command])
                            }
                        }
                        if (showReply) {
                            macOSComposeView(postId: self.postId)
                        }
                    }
                }.padding(8)
                Spacer()
            }
            .onReceive(self.chatStore.$submitPostSuccessMessage) { successMessage in
                if successMessage == "" { return }
                DispatchQueue.main.asyncAfterPostDelay {
                    showReply = false
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color("ThreadBubbleSecondary"))
            .cornerRadius(5)
        }
    }
}

struct macOSPostExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        macOSPostExpandedView(postId: .constant(0), postAuthor: .constant(""), replyLines: .constant(""), lols: .constant([ChatLols]()), postText: .constant([RichTextBlock]()))
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
