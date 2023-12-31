//
//  AlertView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/8/21.
//

import Foundation
import SwiftUI

enum AlertAction {
    case ok
    case cancel
    case others
}

struct AlertView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var shown: Bool
    @Binding var alertAction: AlertAction?
    var message: String
    var cancelOnly: Bool
    var confirmAction: () -> Void = {}

    var body: some View {
        if self.shown {
            VStack {
                Spacer()
                Text(message)
                    .bold()
                    .foregroundColor(Color(UIColor.label))
                    .offset(x: 0, y: 5)
                Spacer()
                Rectangle()
                    .fill(Color(UIColor.systemGray2))
                    .frame(height: 1)
                    .offset(x: 0, y: 8)
                HStack {
                    if cancelOnly {
                        Button(action: {
                            alertAction = .ok
                            confirmAction()
                            withAnimation(.easeOut(duration: 0.1)) {
                                shown.toggle()
                            }
                        }) {
                            Text("OK")
                                .bold()
                                .foregroundColor(Color(UIColor.link))
                        }
                        .frame(width: 200, height: 30)
                        .foregroundColor(.white)
                    } else {
                        Text("Cancel")
                            .bold()
                            .foregroundColor(Color(UIColor.link))
                            .frame(width: 120, height: 30)
                            .contentShape(Rectangle())
                            .onTapGesture(count: 1) {
                                alertAction = .cancel
                                withAnimation(.easeOut(duration: 0.1)) {
                                    shown.toggle()
                                }
                            }
                        Rectangle()
                            .fill(Color(UIColor.systemGray2))
                            .frame(width: 1)
                        Text("Yes")
                            .bold()
                            .foregroundColor(Color(UIColor.link))
                            .frame(width: 120, height: 30)
                            .contentShape(Rectangle())
                            .onTapGesture(count: 1) {
                                alertAction = .ok
                                confirmAction()
                                withAnimation(.easeOut(duration: 0.1)) {
                                    shown.toggle()
                                }
                            }
                    }
                }
                .frame(height: 50)
            }
            .frame(width: 290, height: 120)
            .background(colorScheme == .dark ? Color(UIColor.systemGray4).opacity(0.9) : Color.white.opacity(0.9))
            .cornerRadius(12)
            .clipped()
            .shadow(radius: 5)
            .transition(.scale)
        } else {
            EmptyView()
        }
    }
}
