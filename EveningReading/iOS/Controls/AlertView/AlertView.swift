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
                        .frame(width: 120, height: 30)
                        .foregroundColor(.white)
                    } else {
                        Button(action: {
                            alertAction = .cancel
                            withAnimation(.easeOut(duration: 0.1)) {
                                shown.toggle()
                            }
                        }) {
                            Text("Cancel")
                                .bold()
                                .foregroundColor(Color(UIColor.link))
                        }
                        .frame(width: 120, height: 30)
                        .foregroundColor(.white)
                        Rectangle()
                            .fill(Color(UIColor.systemGray2))
                            .frame(width: 1)
                        Button(action: {
                            alertAction = .ok
                            confirmAction()
                            withAnimation(.easeOut(duration: 0.1)) {
                                shown.toggle()
                            }
                        }) {
                            Text("Yes")
                                .foregroundColor(Color(UIColor.link))
                        }
                        .frame(width: 120, height: 30)
                        .foregroundColor(.white)
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

struct AlertView_Previews: PreviewProvider {
    
    static var previews: some View {
        AlertView(shown: .constant(true), alertAction: .constant(.others), message: "Submit post?", cancelOnly: true)
            .environment(\.colorScheme, .dark)
    }
}
