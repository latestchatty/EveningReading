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
    @EnvironmentObject var viewedPostsStore: ViewedPostsStore
    @Binding var postId: Int
    @Binding var postAuthor: String
    @Binding var replyLines: String?
    @Binding var lols: [ChatLols]
    @Binding var postText: [RichTextBlock]
    @Binding var postDate: String
    @State var showReply = false
    @State var selectedTag: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                // Author
                AuthorNameView(name: self.postAuthor, postId: self.postId, fontWeight: .bold)
                    .frame(width: 100, alignment: .trailing)
                    .help(self.postAuthor)
                
                Text("")
                    .frame(width: 10)

                // Reply lines
                Text(self.replyLines == nil ? String(repeating: " ", count: 5) : self.replyLines!)
                    .lineLimit(1)
                    .fixedSize()
                    .font(.custom("replylines", size: 25, relativeTo: .callout))
                    .foregroundColor(Color.gray)
                
                HStack {
                    Text(self.postDate.getTimeAgo())
                        .padding(.leading, 8)
                        .help(self.postDate.postTimestamp())
                    
                    Spacer()
                    
                    // Lols
                    LolView(lols: self.lols, expanded: true, postId: self.postId)
                        .padding(.top, 5)
                        .padding(.trailing, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(tl: 8, tr: 8, bl: 0, br: 0, color: Color("ThreadBubblePrimary"))
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
                }
                Spacer()
            }
            .onReceive(self.chatStore.$submitPostSuccessMessage) { successMessage in
                if successMessage == "" { return }
                DispatchQueue.main.asyncAfterPostDelay {
                    showReply = false
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .cornerRadius(tl: 8, tr: 0, bl: 8, br: 8, color: Color("ThreadBubblePrimary"))
        }
        .padding(0)
        .onAppear(perform: {
            self.viewedPostsStore.markPostViewed(postId: self.postId)
        })
    }
}

struct macOSPostExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        macOSPostExpandedView(postId: .constant(0), postAuthor: .constant(""), replyLines: .constant(""), lols: .constant([ChatLols]()), postText: .constant([RichTextBlock]()), postDate: .constant("1/1/2020"))
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
