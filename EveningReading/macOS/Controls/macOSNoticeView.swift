//
//  macOSNoticeView.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 6/10/21.
//

import SwiftUI

struct macOSNoticeView : View {
    @Binding public var show: Bool
    public var message: String
    @EnvironmentObject var chatService: ChatService
    
    var body: some View {
        if show {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color.primary)
                        Text(self.message)
                            .foregroundColor(Color.primary)
                    }
                    .frame(width: 120, height: 120)
                    .background(Color(NSColor.systemGray).opacity(0.5))
                    .cornerRadius(20)
                    .onAppear() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                            withAnimation {
                                self.show = false
                            }
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
        } else {
            EmptyView()
        }
    }
}
