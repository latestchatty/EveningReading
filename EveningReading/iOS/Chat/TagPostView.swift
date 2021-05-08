//
//  TagPostView.swift
//  iOS
//
//  Created by Chris Hodge on 7/15/20.
//

import SwiftUI

struct TagPostView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    @State private var showingTagActionSheet = false
    @State private var tag = ""
    
    func tagPost(_ tag: String) {
        
    }

    var body: some View {
        VStack {
            Button(action: {
                self.showingTagActionSheet = true
            }) {
                ZStack{
                    Image(systemName: "circle.fill")
                        .font(.title)
                        .foregroundColor(Color("ActionButton"))
                        .shadow(color: Color("ActionButtonShadow"), radius: 4, x: 0, y: 0)
                    Image(systemName: "tag")
                        .imageScale(.medium)
                        .foregroundColor(self.colorScheme == .dark ? Color(UIColor.white) : Color(UIColor.systemBlue))
                }
            }
            .actionSheet(isPresented: self.$showingTagActionSheet)
            {
                ActionSheet(title: Text("Tags"), message: Text(""), buttons: [
                    .default(Text("lol")) { self.tagPost("lol") },
                    .default(Text("inf")) { self.tagPost("inf") },
                    .default(Text("unf")) { self.tagPost("unf") },
                    .default(Text("tag")) { self.tagPost("tag") },
                    .default(Text("wtf")) { self.tagPost("wtf") },
                    .default(Text("wow")) { self.tagPost("wow") },
                    .default(Text("aww")) { self.tagPost("aww") },
                    .cancel()
                ])
            }
        }
    }
}

struct TagPostView_Previews: PreviewProvider {
    static var previews: some View {
        TagPostView()
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
