//
//  TextView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/26/21.
//

import Foundation
import SwiftUI

class ShackTagService: NSObject, ObservableObject {
    static let shared = ShackTagService()
    
    override init() {
        self.doTagText = false
        super.init()
    }
    
    @Published var doTagText: Bool = false
    @Published var tagWith: String = ""
    @Published var taggedText: String = ""
    var tagAction: () -> Void = {}
    
    var textEditorCurrentRange: UITextRange?
}

struct ShackTagsTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var textStyle: UIFont.TextStyle
    @Binding var doTagText: Bool
    
    func makeUIView(context: Context) -> UITextView {
        let textView = TagMenuItemTextView()
        
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.becomeFirstResponder()
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
        if (ShackTagService.shared.textEditorCurrentRange != nil) {
            uiView.selectedTextRange = ShackTagService.shared.textEditorCurrentRange
            ShackTagService.shared.textEditorCurrentRange = nil
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($text, self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ShackTagsTextView

        var text: Binding<String>

        init(_ text: Binding<String>, _ parent: ShackTagsTextView) {
            self.text = text
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text
            let newRange: UITextRange? = textView.selectedTextRange
            ShackTagService.shared.textEditorCurrentRange = newRange
        }
    }
}

class TagMenuItemTextView: UITextView {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

        // Keep most of the default actions
        // action == #selector(selectAll(_:)) ||
        if action == #selector(cut(_:)) ||
            action == #selector(copy(_:)) ||
            action == #selector(select(_:)) ||
            action == #selector(paste(_:)) ||
            action == Selector(("_promptForReplace:"))
        {
            return true
        }
        
        // Add a custom "Tag" action
        let tagMenuItem = UIMenuItem(title: "Tag", action:#selector(tagText))
        UIMenuController.shared.menuItems = [tagMenuItem]
        UIMenuController.shared.hideMenu()
        if(action == #selector(tagText)){
            return true
        }
        
        // Disable others
        return false
        
    }
    
    // Show TagTextView and update tagAction
    @objc func tagText() {
        if (self.selectedRange.location != NSNotFound ) {
            // Show TagTextView
            ShackTagService.shared.doTagText = true
            
            // Replace selected text with tagged text
            ShackTagService.shared.tagAction = {
                if ShackTagService.shared.tagWith != "" {
                    if let textRange = self.selectedTextRange {
                        if let selectedText = self.text(in: textRange) {
                            // Split tag
                            let halfLength = ShackTagService.shared.tagWith.count / 2
                            let index = ShackTagService.shared.tagWith.index(ShackTagService.shared.tagWith.startIndex, offsetBy: halfLength)
                            ShackTagService.shared.tagWith.insert(";", at: index)
                            let result = ShackTagService.shared.tagWith.split(separator: ";")
                            let tagBegin = result[0]
                            let tagEnd = result[1]
                            
                            // Insert tag text
                            let selectedLocation = self.selectedRange.location
                            let selectedLength = self.selectedRange.length
                            let indexStart = self.text.index(self.text.startIndex, offsetBy: self.selectedRange.location)
                            let indexEnd = self.text.index(self.text.startIndex, offsetBy: self.selectedRange.location + self.selectedRange.length - 1)
                            if indexStart <= indexEnd {
                                let range = indexStart...indexEnd
                                let taggedText = tagBegin + selectedText + tagEnd
                                self.text.replaceSubrange(range, with: taggedText)
                                 
                                // Store the tagged text
                                ShackTagService.shared.taggedText = self.text
                                
                                // Update the currently selected text
                                if let positionStart = self.position(from: self.beginningOfDocument, offset: selectedLocation), let positionEnd = self.position(from: self.beginningOfDocument, offset: selectedLocation + selectedLength + 4) {
                                    self.selectedTextRange = self.textRange(from: positionStart, to: positionEnd)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}
