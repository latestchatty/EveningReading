//
//  macOSNewPostView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 4/5/23.
//

import SwiftUI

struct macOSNewPostView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatStore: ChatStore
    
    public var isRootPost: Bool = false
    public var postId: Int = 0
    
    @State private var postBody = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Text("")
                .sheet(isPresented: $chatStore.showingNewPostSheet) {
                    ZStack {
                        VStack {}.frame(width: 800, height: 450)
                        VStack {
                            HStack {
                                Button(action: {
                                    chatStore.showingNewPostSheet = false
                                }) {
                                    Image(systemName: "xmark")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .padding()
                                .keyboardShortcut(.cancelAction)
                                
                                Text("New Thread")
                                    .bold()
                                    .font(.body)
                                Spacer()
                                
                                
                            }
                            TextEditor(text: self.$postBody)
                                .border(Color.gray)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                        }
                    }
                }
        }
    }
}
