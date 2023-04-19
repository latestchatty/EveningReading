//
//  ShackTagsTextView.swift
//  EveningReading (macOS)
//
//  Created by Willie Zutz on 8/19/21.
//

import Foundation
import SwiftUI
import AppKit
import Cocoa
import Combine

/*
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
*/

struct ShackTagsTextView: NSViewRepresentable {
    
    private var text: Binding<String>
    private var disabled: Binding<Bool>
    
    @ObservedObject private var textContext: TextContext
    
    let scrollView = NSTextView.scrollableTextView()
    var textView: NSTextView {
        scrollView.documentView as! NSTextView
    }
    
    public init(
        text: Binding<String>,
        disabled: Binding<Bool>,
        textContext: TextContext
    ) {
        self.text = text
        self.disabled = disabled
        self._textContext = ObservedObject(wrappedValue: textContext)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        //let textView = TagMenuItemTextView()
        //let scrollView = NSTextView.scrollableTextView()
        //let textView = scrollView.documentView as! NSTextView
        
        textView.delegate = context.coordinator
        textView.font = NSFont.preferredFont(forTextStyle: NSFont.TextStyle.body)
        //textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isContinuousSpellCheckingEnabled = true
        textView.isEditable = !disabled.wrappedValue
        //textView.isUserInteractionEnabled = true
        
        // Guess we have to wait for it to be added to make it first responder.
        DispatchQueue.main.async {
            if textView.acceptsFirstResponder {
                textView.window?.makeFirstResponder(textView)
            }
        }
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text, textView: textView, textContext: textContext)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>
        public private(set) var textView: NSTextView
        public let textContext: TextContext

        public var cancellables = Set<AnyCancellable>()
        
        init(_ text: Binding<String>, textView: NSTextView, textContext: TextContext) {
            self.text = text
            self.textView = textView
            self.textContext = textContext
            super.init()
            self.subscribeToContextChanges()
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            self.text.wrappedValue = textView.string
        }
        
        func subscribeToContextChanges() {
            subscribeToRed()
            subscribeToGreen()
            subscribeToBlue()
            subscribeToYellow()
            subscribeToLime()
            subscribeToOrange()
            subscribeToPink()
            subscribeToOlive()
            subscribeToItalic()
            subscribeToBold()
            subscribeToQuote()
            subscribeToSample()
            subscribeToUnderline()
            subscribeToStrike()
            subscribeToSpoiler()
            subscribeToCode()
        }
        
        func subscribeToRed() {
            textContext.$isRed
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.red, to: $0) })
                .store(in: &cancellables)
        }
        
        func subscribeToGreen() {
            textContext.$isGreen
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.green, to: $0) })
                .store(in: &cancellables)
        }
        
        func subscribeToBlue() {
            textContext.$isBlue
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.blue, to: $0) })
                .store(in: &cancellables)
        }
        
        func subscribeToYellow() {
            textContext.$isYellow
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.yellow, to: $0) })
                .store(in: &cancellables)
        }
        
        func subscribeToLime() {
            textContext.$isLime
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.lime, to: $0) })
                .store(in: &cancellables)
        }
        
        func subscribeToOrange() {
            textContext.$isOrange
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.orange, to: $0) })
                .store(in: &cancellables)
        }
        
        func subscribeToPink() {
            textContext.$isPink
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.pink, to: $0) })
                .store(in: &cancellables)
        }
        
        func subscribeToOlive() {
            textContext.$isOlive
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.olive, to: $0) })
                .store(in: &cancellables)
        }
        
        func subscribeToItalic() {
            textContext.$isItalic
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.italic, to: $0) })
                .store(in: &cancellables)
        }
        
        func subscribeToBold() {
            textContext.$isBold
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.bold, to: $0) })
                .store(in: &cancellables)
        }
        
        func subscribeToQuote() {
            textContext.$isQuote
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.quote, to: $0) })
                .store(in: &cancellables)
        }
        
        func subscribeToSample() {
            textContext.$isSample
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.sample, to: $0) })
                .store(in: &cancellables)
        }
                
        func subscribeToUnderline() {
            textContext.$isUnderline
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.underline, to: $0) })
                .store(in: &cancellables)
        }
        
        func subscribeToStrike() {
            textContext.$isStrike
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.strike, to: $0) })
                .store(in: &cancellables)
        }
        
        func subscribeToSpoiler() {
            textContext.$isSpoiler
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.spoiler, to: $0) })
                .store(in: &cancellables)
        }
        
        func subscribeToCode() {
            textContext.$isCode
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in self?.setStyle(.code, to: $0) })
                .store(in: &cancellables)
        }
        
        func setStyle(_ style: TextStyle, to newValue: Bool) {
            if text.wrappedValue.isEmpty { return }
            if textView.selectedRange().location == NSNotFound { return }
            var string = textView.attributedString().string
            
            var styleText = style.rawValue
            let halfLength = styleText.count / 2
            let fullLength = styleText.count
            let index = styleText.index(styleText.startIndex, offsetBy: halfLength)
            styleText.insert(";", at: index)
            let result = styleText.split(separator: ";")
            if result.count < 1 { return }
            
            let selectedRange = textView.selectedRange()
            let startIndex = string.index(string.startIndex, offsetBy: selectedRange.lowerBound)
            let endIndex = string.index(string.startIndex, offsetBy: selectedRange.upperBound)
            let substring = textView.attributedString().string[startIndex..<endIndex]
            
            string.insert(contentsOf: result[1], at: string.index(endIndex, offsetBy: 0))
            string.insert(contentsOf: result[0], at: string.index(startIndex, offsetBy: 0))
                        
            textView.string = string
            self.text.wrappedValue = string

            textView.setSelectedRange(NSRange(location: endIndex.encodedOffset + fullLength, length: 0))

            let selectedString = String(substring)
            print("log: setting style \(selectedString)")
        }
    }
}

public class TextContext: ObservableObject {
    public init() {}
    public internal(set) var selectedRange = NSRange()
    
    @Published public var isRed = false
    @Published public var isGreen = false
    @Published public var isBlue = false
    @Published public var isYellow = false
    @Published public var isLime = false
    @Published public var isOrange = false
    @Published public var isPink = false
    @Published public var isOlive = false
    @Published public var isItalic = false
    @Published public var isBold = false
    @Published public var isQuote = false
    @Published public var isSample = false
    @Published public var isUnderline = false
    @Published public var isStrike = false
    @Published public var isSpoiler = false
    @Published public var isCode = false
}

public enum TextStyle: String {
    case red = "r{}r"
    case green = "g{}g"
    case blue = "b{}b"
    case yellow = "y{}y"
    case lime = "l[]l"
    case orange = "n[]n"
    case pink = "p[]p"
    case olive = "e[]e"
    case italic = "/[]/"
    case bold = "b[]b"
    case quote = "q[]q"
    case sample = "s[]s"
    case underline = "_[]_"
    case strike = "-[]-"
    case spoiler = "o[]o"
    case code = "/{{}}/"
}

//extension NSTextView {
//    var selectedText: String {
//        var text = ""
//        for case let range as NSRange in self.selectedRanges {
//            text.append(string[range]+"\n")
//        }
//        text = String(text.dropLast())
//        return text
//    }
//}
//
//extension String {
//    subscript (_ range: NSRange) -> Self {
//        .init(self[index(startIndex, offsetBy: range.lowerBound) ..< index(startIndex, offsetBy: range.upperBound)])
//    }
//}

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
