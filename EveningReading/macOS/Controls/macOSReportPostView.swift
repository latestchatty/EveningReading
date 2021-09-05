//
//  macOSReportPostView.swift
//  EveningReading (macOS)
//
//  Created by Willie Zutz on 9/5/21.
//

import SwiftUI

struct macOSReportPostView: View {
    @EnvironmentObject private var messageStore: MessageStore
    var postId: Int
    var postAuthor: String
    @Binding var showReportPost: Bool
    
    var body: some View {
        macOSTextPromptSheet(action: {text, promptResult in
            self.messageStore.submitComplaint(author: self.postAuthor, postId: self.postId, reason: text, handler: { messageResult in
                switch messageResult {
                case .success(let s):
                    promptResult(.success(s))
                case .failure(let err):
                    promptResult(.failure(err))
                }
            })
        },
        label: {
            Text("Do you want to report this post for violating community guidelines?\r\nBriefly explain why it does in the field below.")
        },
        showPrompt: self.$showReportPost,
        title: "Report Post")
        Button(action: {
            self.showReportPost = true
        }, label: {
            Image(systemName: "exclamationmark.triangle")
                .imageScale(.large)
        })
        .buttonStyle(BorderlessButtonStyle())
        .foregroundColor(Color.primary)
        .help("Report post for community guideline violation")
    }
}

struct macOSReportPostView_Previews: PreviewProvider {
    static var previews: some View {
        macOSReportPostView(postId: 0, postAuthor: "", showReportPost: .constant(true))
    }
}
