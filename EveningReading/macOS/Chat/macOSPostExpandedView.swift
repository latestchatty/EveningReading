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
    @State var replyText = ""
    @State var postDisabled = false

    var body: some View {
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
                            Image(systemName: "tag")
                                .imageScale(.large)
                                .onTapGesture(count: 1) {
                                }
                            Image(systemName: "arrowshape.turn.up.left")
                                .imageScale(.large)
                                .foregroundColor(showReply ? Color.accentColor : Color.primary)
                                .onTapGesture(count: 1) {
                                    showReply = !showReply
                                }
                        }
                    }
                    if (showReply) {
                        TextEditor(text: $replyText)
                            .disabled(postDisabled)
                            .overlay(RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.primary, lineWidth: 2))
                            .padding(.top, 8)
                            .frame(minHeight: 65)
                        HStack() {
                            Spacer()
                            Image(systemName: "paperplane")
                                .imageScale(.large)
                                .disabled(postDisabled)
                                .onTapGesture(count:1) {
                                    print(replyText)
                                    postDisabled = true
                                    // Let the loading indicator show for at least a short time
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                                        self.chatStore.submitPost(postBody: self.replyText, postId: self.postId)
                                    }
                                }
                        }
                    }
                }
            }.padding(8)
            Spacer()
        }
        .onReceive(self.chatStore.$submitPostSuccessMessage) { successMessage in
            DispatchQueue.main.async {
                postDisabled = false
                replyText = ""
                showReply = false
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    self.chatStore.getThread()
                }
            }
        }
        .onReceive(self.chatStore.$submitPostErrorMessage) { errorMessage in
            DispatchQueue.main.async {
                print(errorMessage)
                postDisabled = false
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color("ThreadBubbleSecondary"))
        .cornerRadius(5)
    }
}

struct macOSPostExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        macOSPostExpandedView(postId: .constant(0), postAuthor: .constant(""), replyLines: .constant(""), lols: .constant([ChatLols]()), postText: .constant([RichTextBlock]()))
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
