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
    @EnvironmentObject var messageStore: MessageStore
    @Binding var postId: Int
    @Binding var postAuthor: String
    @Binding var postAuthorType: AuthorType
    @Binding var replyLines: String?
    @Binding var lols: [ChatLols]
    @Binding var postText: [RichTextBlock]
    @Binding var postDate: String
    @State var showReply = false
    @State var selectedTag: String = ""
    @State var showReportPost = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                // Author
                AuthorNameView(name: self.postAuthor, postId: self.postId, authorType: self.postAuthorType, fontWeight: .bold)
                    .frame(width: 100, alignment: .trailing)
                    .help(self.postAuthor)
                
                Text("")
                    .frame(width: 10)
                
                // Reply lines
                Text(self.replyLines == nil ? String(repeating: " ", count: 5) : self.replyLines!)
                    .lineLimit(1)
                    .fixedSize()
                    .font(.custom("replylines", size: 25 + FontSettings.instance.fontOffset, relativeTo: .callout))
                    .foregroundColor(Color.gray)
                
                HStack {
                    Text(self.postDate.getTimeAgo())
                        .foregroundColor(Color.gray)
                        .padding(.leading, 8)
                        .help(self.postDate.postTimestamp())
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(tl: 8, tr: 8, bl: 0, br: 0, color: Color("ThreadBubblePrimary"))
            }
            
            HStack {
                VStack (alignment: .leading) {
                    // Full post
                    RichTextView(topBlocks: self.postText)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack() {
                        HStack {
                            if appSessionStore.isSignedIn {
                                TagPostButton(postId: self.postId)
                                    .padding(.trailing, 8)
                            }
                            
                            // Lols
                            LolView(lols: self.lols, expanded: true, postId: self.postId)
                                .padding(.top, 5)
                                .padding(.trailing, 10)
                            
                            Spacer()
                            
                            macOSReportPostView(postId: self.postId, postAuthor: self.postAuthor, showReportPost: self.$showReportPost)
                            
                            Button(action: {
                                // TODO: Should show some type of indication that this happened.
                                // Maybe something like https://github.com/elai950/AlertToast
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString("https://www.shacknews.com/chatty?id=\(self.postId)#item_\(self.postId)", forType: .URL)
                            }, label: {
                                Image(systemName: "link")
                                    .imageScale(.large)
                            })
                            .buttonStyle(BorderlessButtonStyle())
                            .foregroundColor(Color.primary)
                            .help("Copy link to post")
                            
                            if appSessionStore.isSignedIn {
                                Button(action: {
                                    showReply = !showReply
                                }, label: {
                                    Image(systemName: "arrowshape.turn.up.left")
                                        .imageScale(.large)
                                        .foregroundColor(showReply ? Color.accentColor : Color.secondary)
                                })
                                .buttonStyle(BorderlessButtonStyle())
                                .help("Reply to post")
                                .keyboardShortcut("r", modifiers: [.command])
                            }
                        }
                    }
                    if (showReply) {
                        macOSComposeView(postId: self.postId)
                            .padding(.top, 8)
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
        macOSPostExpandedView(postId: .constant(0), postAuthor: .constant(""), postAuthorType: .constant(.none), replyLines: .constant(""), lols: .constant([ChatLols]()), postText: .constant([RichTextBlock]()), postDate: .constant("1/1/2020"))
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
