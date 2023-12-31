//
//  watchOSPostPreview.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct watchOSPostPreview: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService
    
    @Binding var postId: Int
    @Binding var replyText: String
    @Binding var author: String
    
    @State private var showingPost: Bool = false
    
    @ObservedObject private var watchService = WatchService.shared
    
    var body: some View {
        HStack {
            Button(action: {
                self.showingPost.toggle()
            }) {
                HStack {
                    Text("\(appService.getPostBodyFor(name: author, body: self.replyText))")
                        .font(.footnote)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .padding()
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            .background(
                watchService.plainTextUsername == author.lowercased() ? Color("ThreadBubbleContributed") : Color("ThreadBubbleSecondary")
            )
            .cornerRadius(5)
            
            NavigationLink(destination: watchOSPostDetail(postId: .constant(self.postId)).environmentObject(appService).environmentObject(chatService), isActive: self.$showingPost) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            
            // Fixes NavLink bug in SwiftUI?
            NavigationLink(destination: EmptyView()) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
        }
    }
}
