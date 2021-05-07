//
//  RefreshNoticeView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/7/21.
//

import SwiftUI

struct RefreshNoticeView : View {
    @Binding var showingNotice: Bool

    var body: some View {
        if self.showingNotice {
            VStack {
                Text("You're up to date!")
                    .font(.title)
                    .foregroundColor(Color.primary)
            }
            .frame(width: 200, height: 200)
            .background(Color.gray)
            .opacity(0.8)
            .cornerRadius(20)
            .onAppear(perform: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    withAnimation {
                        self.showingNotice = false
                    }
                })
            })
        } else {
            EmptyView()
        }
    }
}

struct RefreshNoticeView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshNoticeView(showingNotice: .constant(true))
    }
}
