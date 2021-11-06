//
//  macOSTextPromptSheet.swift
//  EveningReading (macOS)
//
//  Created by Willie Zutz on 9/5/21.
//

import Foundation
import SwiftUI

struct macOSTextPromptSheet<Label>: View where Label : View {
    @Binding var showPrompt: Bool
    let action: (_ text: String, _ handler: @escaping (Result<Bool, Error>) -> Void) -> Void
    let label: Label
    let title: String
    let acceptButtonContent: String
    let useShackTagsInput: Bool
    @State var inputText: String = ""
    @State var submitting: Bool = false
    
    init(action: @escaping (_ text: String, _ handler: @escaping (Result<Bool, Error>) -> Void) -> Void,
         @ViewBuilder label: () -> Label,
         showPrompt: Binding<Bool>,
         title: String, acceptButtonContent: String = "Accept",
         useShackTagsInput: Bool = false) {
        self.action = action
        self.label = label()
        self._showPrompt = showPrompt
        self.title = title
        self.acceptButtonContent = acceptButtonContent
        self.useShackTagsInput = useShackTagsInput
    }
    
    var body: some View {
        EmptyView()
            .sheet(isPresented: self.$showPrompt) {
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {self.showPrompt = false}) {
                            Image(systemName: "xmark")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .keyboardShortcut(.cancelAction)
                        
                        Text(title)
                            .bold()
                            .font(.body)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    self.label
                        .padding(.bottom, 8)
                    
                    if useShackTagsInput {
                        ShackTagsTextView(text: self.$inputText, disabled: self.$submitting)
                            .frame(minHeight: 100)
                            .overlay(RoundedRectangle(cornerRadius: 4)
                                        .stroke(self.inputText.count < 6 ? Color.red : Color.primary, lineWidth: 2))
                    } else {
                        TextField(self.title, text: self.$inputText)
                            .disabled(self.submitting)
                    }
                    
                    HStack {
                        Spacer()
                        Button(self.acceptButtonContent, action: {
                            self.submitting = true
                            self.action(self.inputText) { result in
                                switch result {
                                    case .success:
                                        self.inputText = ""
                                        self.showPrompt = false
                                    case .failure(let error):
                                        print(error)
                                }
                                self.submitting = false
                            }
                        })
                        .disabled(self.submitting)
                        .keyboardShortcut(KeyEquivalent.return, modifiers: [.command])
                    }
                }
                .padding()
                .frame(minWidth: 800)
                .overlay(LoadingView(show: self.$submitting, title: .constant("")))
            }
    }
}
