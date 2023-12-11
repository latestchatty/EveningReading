//
//  NoticeView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/9/21.
//

import SwiftUI

struct NoticeView : View {
    @Binding public var show: Bool
    public var message: String
    @EnvironmentObject var chatService: ChatService
    
    var body: some View {
        #if os(macOS)
        if show {
            VStack {
                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.primary)
                Text(self.message)
                    .foregroundColor(Color.primary)
            }
            .frame(width: 120, height: 120)
            .background(BlurView())
            .cornerRadius(20)
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    withAnimation {
                        self.show = false
                    }
                }
            }
        } else {
            EmptyView()
        }
        #else
        if show {
            VStack {
                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.primary)
                Text(self.message)
                    .foregroundColor(Color.primary)
            }
            .frame(width: 120, height: 120)
            .background(BlurView(style: .systemUltraThinMaterial))
            .cornerRadius(20)
            .onAppear() {
                print("Show Notice")
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    withAnimation {
                        self.show = false
                    }
                }
            }
        } else {
            EmptyView()
        }
        #endif
    }
}
