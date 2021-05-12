//
//  ThreadNavigationView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/9/21.
//

import SwiftUI

struct ThreadNavigationView: View {
    @Binding var icon: String
    var action: () -> Void = {}
    @State private var doWiggle = false
    
    var body: some View {
        Image(systemName: self.icon)
            .padding(.init(top: 10, leading: self.icon == "arrow.up" ? 10 : 4, bottom: 10, trailing: self.icon == "arrow.up" ? 4 : 10))
            .onTapGesture(count: 1) {
                action()
            }
    }
}

struct DisabledThreadNavigationView: View {
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "arrow.up")
                    .foregroundColor(Color(UIColor.systemGray))
                    .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 4))
                Rectangle()
                    .fill(Color(UIColor.systemGray))
                    .frame(width: 1, height: 20)
                Image(systemName: "arrow.down")
                    .foregroundColor(Color(UIColor.systemGray))
                    .padding(.init(top: 10, leading: 4, bottom: 10, trailing: 10))
            }
        }
        .background(Color(UIColor.systemGray3).opacity(0.9))
        .cornerRadius(12)
        .clipped()
        .padding(.init(top: 0, leading: 0, bottom: 50, trailing: 50))
        .shadow(radius: 5)
    }
}
