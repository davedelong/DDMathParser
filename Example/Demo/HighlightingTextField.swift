//
//  File.swift
//  
//
//  Created by Dave DeLong on 8/7/21.
//

import SwiftUI
#if canImport(Cocoa)
import Cocoa
#endif

@available(macOS 11.0, *)
struct HighlightingTextField: NSViewRepresentable {
    
    @Binding var text: String
    var highlights: Set<Range<Int>>
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(binding: $text)
    }
    
    func makeNSView(context: Context) -> NSTextField {
        let tf = NSTextField()
        tf.allowsEditingTextAttributes = true
        context.coordinator.observe(tf)
        return tf
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        let t = text
        let s = NSMutableAttributedString(string: t)
        for range in highlights {
            let l = t.index(t.startIndex, offsetBy: range.lowerBound)
            let u = t.index(t.startIndex, offsetBy: range.upperBound)
            let characterRange = NSRange(l ..< u, in: t)
            
            s.addAttribute(.foregroundColor, value: NSColor.red, range: characterRange)
        }
        print(s)
        nsView.attributedStringValue = s
    }
    
    class Coordinator: NSObject {
        let binding: Binding<String>
        var token: AnyObject?
        
        init(binding: Binding<String>) {
            self.binding = binding
            super.init()
        }
        
        deinit {
            if let t = token {
                NotificationCenter.default.removeObserver(t)
            }
        }
        
        func observe(_ textField: NSTextField) {
            if let t = token {
                NotificationCenter.default.removeObserver(t)
            }
            token = NotificationCenter.default.addObserver(forName: NSControl.textDidChangeNotification, object: textField, queue: .main, using: { [weak self, weak textField] _ in
                let text = textField?.stringValue ?? ""
                self?.binding.wrappedValue = text
            })
        }
        
    }
}
