//
//  macOSComposeView.swift
//  EveningReading (macOS)
//
//  Created by Willie Zutz on 8/17/21.
//

import SwiftUI

struct macOSComposeView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    var postId: Int
    @State var replyText = ""
    @State var submitInProgress = false
    @State private var postStyle = NSFont.TextStyle.body
    
    var body: some View {
        VStack(alignment: .leading) {
            //TextEditor(text: $replyText)
            ShackTagsTextView(text: $replyText, textStyle: $postStyle, disabled: $submitInProgress)
                .frame(minHeight: 100)
                .overlay(RoundedRectangle(cornerRadius: 4)
                            .stroke(replyText.count < 6 ? Color.red : Color.primary, lineWidth: 2))
            
            HStack() {
                Spacer()
                Button(action: {
                    submitInProgress = true
                    self.chatStore.submitPost(postBody: self.replyText, postId: self.postId)
                }, label: {
                    Image(systemName: "paperplane")
                        .imageScale(.large)
                })
                .disabled(submitInProgress || replyText.count < 6)
                .buttonStyle(BorderlessButtonStyle())
                .padding(.top, 8)
                .help("Submit post")
                .keyboardShortcut(KeyEquivalent.return, modifiers: [.command])
            }
        }
        .onReceive(self.chatStore.$submitPostSuccessMessage) { successMessage in
            if successMessage == "" { return }
            DispatchQueue.main.asyncAfterPostDelay {
                submitInProgress = false
                replyText = ""
            }
        }
        
        .onReceive(self.chatStore.$submitPostErrorMessage) { errorMessage in
            if errorMessage == "" { return }
            DispatchQueue.main.async {
                print(errorMessage)
                submitInProgress = false
            }
        }
        .overlay(LoadingView(show: $submitInProgress, title: .constant("")))
    }
}

struct macOSComposeView_Previews: PreviewProvider {
    static var previews: some View {
        macOSComposeView(postId: 0)
            .environmentObject(ChatStore(service: ChatService()))
    }
}
