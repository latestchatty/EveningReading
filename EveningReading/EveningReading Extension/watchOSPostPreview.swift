//
//  watchOSPostPreview.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/4/21.
//

import SwiftUI

struct watchOSPostPreview: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
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
                    Text("\(appSessionStore.blockedAuthors.contains(author) ? "[blocked]" : self.replyText)")
                        .font(.footnote)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .padding()
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            .background(
                watchService.username == author.lowercased() ? Color("ThreadBubbleContributed") : Color("ThreadBubbleSecondary")
            )
            .cornerRadius(5)
            
            NavigationLink(destination: watchOSPostDetail(postId: .constant(self.postId)).environmentObject(appSessionStore).environmentObject(chatStore), isActive: self.$showingPost) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            
            // Fixes NavLink bug in SwiftUI?
            // https://developer.apple.com/forums/thread/677333
            NavigationLink(destination: EmptyView()) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
        }
    }
}

struct watchOSPostPreview_Previews: PreviewProvider {
    static var previews: some View {
        watchOSPostPreview(postId: .constant(999999992), replyText: .constant("Quis hendrerit dolor magna eget."), author: .constant("Tim"))
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}

