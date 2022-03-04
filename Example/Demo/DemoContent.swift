//
//  File.swift
//  
//
//  Created by Dave DeLong on 8/7/21.
//

import SwiftUI

@available(macOS 11.0, *)
class DemoAppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let content = NSHostingController(rootView: DemoContent())
        content.view.frame.size = content.view.fittingSize
        window = NSWindow(contentViewController: content)
        window?.title = "MathParser Demo"
        window?.makeKeyAndOrderFront(self)
    }
}

struct DemoContent: View {
    @StateObject var analyzer = Analyzer()
    @State var highlights = Set<Range<Int>>()
    
    private var highlightedRanges: Set<Range<Int>> {
        if let e = analyzer.error {
            return [e.range]
        } else {
            return highlights
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HighlightingTextField(text: $analyzer.rawExpression, highlights: highlightedRanges)
                .frame(maxWidth: .infinity)
            
            Text(errorMessage)
                .multilineTextAlignment(.leading)
                .font(.caption)
                .foregroundColor(analyzer.error != nil ? .red : .secondary)
            
            Spacer()
            
            TabView {
                RawTokens(analyzer: analyzer)
                ResolvedTokens(analyzer: analyzer)
                GroupedTokens(analyzer: analyzer)
                Expressions(analyzer: analyzer)
                Variables(analyzer: analyzer)
            }
            .tabViewStyle(DefaultTabViewStyle())
        }
        .padding(20)
        .frame(minWidth: 300, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
    }
    
    private var errorMessage: String {
        let msg: String
        if let error = analyzer.error {
            switch error.kind {
                case .ambiguousOperator: msg = "Unable to disambiguate operator"
                case .cannotParseExponent: msg = "Unable to parse exponent"
                case .cannotParseFractionalNumber: msg = "Unable to parse fraction"
                case .cannotParseNumber: msg = "Unable to parse number"
                case .cannotParseHexNumber: msg = "Unable to parse hexadecimal number"
                case .cannotParseOctalNumber: msg = "Unable to parse octal number"
                case .cannotParseIdentifier: msg = "Unable to parse identifier"
                case .cannotParseVariable: msg = "Unable to parse variable"
                case .cannotParseQuotedVariable: msg = "Unable to parse quoted variable"
                case .cannotParseOperator: msg = "Unable to parse operator"
                case .zeroLengthVariable: msg = "Variables must have at least one character"
                case .cannotParseLocalizedNumber: msg = "Unable to parse localized number"
                case .unknownOperator: msg = "Unknown operator"
                case .missingOpenParenthesis: msg = "Expression is missing open parenthesis"
                case .missingCloseParenthesis: msg = "Expression is missing closing parenthesis"
                case .emptyFunctionArgument: msg = "Function is missing argument"
                case .emptyGroup: msg = "Empty group"
                case .invalidFormat: msg = "Expression is likely missing an operator"
                case .missingLeftOperand(let o): msg = "Operator \(o.tokens.first!) is missing its left operand"
                case .missingRightOperand(let o): msg = "Operator \(o.tokens.first!) is missing its right operand"
                case .unknownFunction(let f): msg = "Unknown function '\(f)'"
                case .unknownVariable(let v): msg = "Unknown variable '\(v)'"
                case .divideByZero: msg = "Invalid division by zero"
                case .invalidArguments: msg = "Invalid arguments to function"
            }
        } else {
            msg = "No error"
        }
        return msg
    }
}
