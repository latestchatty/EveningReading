//
//  ComposePostView.swift
//  iOS
//
//  Created by Chris Hodge on 7/7/20.
//

import SwiftUI
import Photos

struct ComposePostView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    public var isRootPost: Bool = false
    
    @State private var showingComposeSheet = false

    private func submitPost() {
        
    }
        
    private func uploadImageToImgur(image: UIImage) {
        
    }
    
    var body: some View {
        VStack {
            if self.appSessionStore.isSignedIn || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
                Button(action: {
                    DispatchQueue.main.async {
                        self.showingComposeSheet = true
                    }
                }) {
                    ZStack {
                        if !self.isRootPost {
                            Image(systemName: "circle.fill")
                                .font(.title)
                                .foregroundColor(Color("ActionButton"))
                                .shadow(color: Color("ActionButtonShadow"), radius: 4, x: 0, y: 0)
                        }
                        Image(systemName: self.isRootPost ? "square.and.pencil" : "arrowshape.turn.up.left")
                            .imageScale(!self.isRootPost ? .medium : .large)
                            .foregroundColor(self.colorScheme == .dark ? Color(UIColor.white) : Color(UIColor.systemBlue))
                    }
                }
            }
        }
    }
}

struct ComposePostView_Previews: PreviewProvider {
    static var previews: some View {
        ComposePostView(isRootPost: false)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
