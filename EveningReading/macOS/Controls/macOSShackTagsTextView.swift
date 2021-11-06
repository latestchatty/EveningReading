//
//  ShackTagsTextView.swift
//  EveningReading (macOS)
//
//  Created by Willie Zutz on 8/19/21.
//

import Foundation
import SwiftUI

class ShackTags: NSObject, ObservableObject {
    static let shared = ShackTags()
    
    override init() {
        //self.doTagText = false
        super.init()
    }
    
    //@Published var doTagText: Bool = false
    @Published var tagWith: String = ""
    @Published var taggedText: String = ""
    var tagAction: () -> Void = {}
}

struct ShackTagsTextView: NSViewRepresentable {
    
    @Binding var text: String
    @Binding var disabled: Bool
    //@Binding var doTagText: Bool
    
    func makeNSView(context: Context) -> NSScrollView {
        //let textView = TagMenuItemTextView()
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        textView.delegate = context.coordinator
        textView.font = NSFont.init(name: Font.defaultFontName, size: Font.defaultFontBodyFontSize + FontSettings.instance.fontOffset)
        //textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isContinuousSpellCheckingEnabled = true
        textView.isEditable = !disabled
        //textView.isUserInteractionEnabled = true
        
        // Guess we have to wait for it to be added to make it first responder.
        DispatchQueue.main.async {
            if textView.acceptsFirstResponder {
                textView.window?.makeFirstResponder(textView)
            }
        }
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        // get wrapped nsTextView
        guard let nsTextView = scrollView.documentView as? NSTextView else {
           return
        }

        nsTextView.font = NSFont.init(name: Font.defaultFontName, size: Font.defaultFontBodyFontSize + FontSettings.instance.fontOffset)
        nsTextView.isEditable = !self.disabled
        // Re-setting it if it's already the same ends up moving the cursor to the end.
        // So we need to protect against that.
        guard nsTextView.string != text else { return }
        nsTextView.string = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>

        init(_ text: Binding<String>) {
            self.text = text
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            self.text.wrappedValue = textView.string
        }
    }
}

//class TagMenuItemTextView: NSTextView {
//
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//
//        // Keep most of the default actions
//        if action == #selector(cut(_:)) ||
//            action == #selector(copy(_:)) ||
//            action == #selector(select(_:)) ||
//            action == #selector(selectAll(_:)) ||
//            action == #selector(paste(_:)) ||
//            action == Selector(("_promptForReplace:"))
//        {
//            return true
//        }
//
//        // Add a custom "Tag" action
//        let tagMenuItem = NSMenuItem(title: "Tag", action:#selector(tagText))
//        NSMenuController.shared.menuItems = [tagMenuItem]
//        NSMenuController.shared.hideMenu()
//        if(action == #selector(tagText)){
//            return true
//        }
//
//        // Disable others
//        return false
//
//    }
//
//    // Show TagTextView and update tagAction
//    @objc func tagText() {
//        if (self.selectedRange.location != NSNotFound ) {
//            // Show TagTextView
//            ShackTags.shared.doTagText = true
//
//            // Replace selected text with tagged text
//            ShackTags.shared.tagAction = {
//                if ShackTags.shared.tagWith != "" {
//                    if let textRange = self.selectedTextRange {
//                        if let selectedText = self.text(in: textRange) {
//                            // Split tag
//                            let halfLength = ShackTags.shared.tagWith.count / 2
//                            let index = ShackTags.shared.tagWith.index(ShackTags.shared.tagWith.startIndex, offsetBy: halfLength)
//                            ShackTags.shared.tagWith.insert(";", at: index)
//                            let result = ShackTags.shared.tagWith.split(separator: ";")
//                            let tagBegin = result[0]
//                            let tagEnd = result[1]
//
//                            // Insert tag text
//                            let selectedLocation = self.selectedRange.location
//                            let selectedLength = self.selectedRange.length
//                            let indexStart = self.text.index(self.text.startIndex, offsetBy: self.selectedRange.location)
//                            let indexEnd = self.text.index(self.text.startIndex, offsetBy: self.selectedRange.location + self.selectedRange.length - 1)
//                            if indexStart <= indexEnd {
//                                let range = indexStart...indexEnd
//                                let taggedText = tagBegin + selectedText + tagEnd
//                                self.text.replaceSubrange(range, with: taggedText)
//
//                                // Store the tagged text
//                                ShackTags.shared.taggedText = self.text
//
//                                // Update the currently selected text
//                                if let positionStart = self.position(from: self.beginningOfDocument, offset: selectedLocation), let positionEnd = self.position(from: self.beginningOfDocument, offset: selectedLocation + selectedLength + 4) {
//                                    self.selectedTextRange = self.textRange(from: positionStart, to: positionEnd)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//}
