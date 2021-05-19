//
//  NotificationPreviewView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct NotificationPreviewView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSessionStore: AppSessionStore
    var title: String
    var postBody: String
    var postId: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(UIColor.systemOrange))
                    .lineLimit(1)
            }
            .frame(alignment: .leading)
            .padding(EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10))
            Spacer()
            Text("\(self.postBody)")
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(2)
                .padding(.trailing, 20)
            Spacer()
            Button(action: {
                for index in 0...appSessionStore.pushNotifications.count {
                    if appSessionStore.pushNotifications[index].postId == self.postId {
                        appSessionStore.pushNotifications.remove(at: index)
                        break
                    }
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .imageScale(.small)
                    .foregroundColor(.white)
                    .frame(width: 22)
                    .padding(.trailing, 20)
            }
        }
        .background(Color("ArticleCardBackground"))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 10)
        .frame(maxWidth: 350)
    }
}

struct NotificationPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPreviewView(title: "kazantzis", postBody: "Amet volutpat consequat mauris nunc congue nisi vitae.", postId: 0)
            .environmentObject(AppSessionStore(service: AuthService()))
            
    }
}
