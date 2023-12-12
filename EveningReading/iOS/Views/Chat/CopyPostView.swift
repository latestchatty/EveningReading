//
//  CopyPostView.swift
//  iOS
//
//  Created by Chris Hodge on 7/7/20.
//

import SwiftUI
import Photos

struct CopyPostView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var chatService: ChatService
    
    @State private var postWebViewHeight: CGFloat = .zero
    
    var body: some View {
        VStack {
            Spacer().frame(width: 0, height: 0)

            // Compose Post Sheet
            .sheet(isPresented: $chatService.showingCopyPostSheet,
               onDismiss: {
                    chatService.copyPostText = ""
               }) {
               ScrollView {
                   HStack {
                       Spacer()
                       Button(action: { chatService.showingCopyPostSheet = false }) {
                           Rectangle()
                               .foregroundColor(Color(UIColor.systemFill))
                               .frame(width: 40, height: 5)
                               .cornerRadius(3)
                               .opacity(0.5)
                       }
                       Spacer()
                   }
                   .padding(.top, 10)
                   .padding(.bottom, 20)
                   
                   HStack {
                       Spacer()
                       Text("Select Text")
                           .bold()
                           .font(.body)
                       Spacer()
                   }
                   
                   HStack {
                       PostWebView(viewModel: PostWebViewModel(author: "", body: chatService.copyPostText, colorScheme: colorScheme), dynamicHeight: $postWebViewHeight)
                   }
                   .frame(height: postWebViewHeight)
                   .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
               }
            }
        }
    }
}
