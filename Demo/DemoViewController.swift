//
//  DemoWindowController.swift
//  Demo
//
//  Created by Dave DeLong on 11/21/17.
//

import Cocoa
import MathParser

class DemoViewController: NSViewController, AnalyzerDelegate, NSTextFieldDelegate {

    @IBOutlet var expressionField: NSTextField?
    @IBOutlet var errorLabel: NSTextField?
    @IBOutlet var flowContainer: NSView?
    
    var flowController: AnalyzerFlowViewController?

    private var controlChangeObserver: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = flowContainer! // must have outlet hooked up

        let flow = AnalyzerFlowViewController()
        flow.analyzerDelegate = self
        addChild(flow)
        
        flow.view.frame = container.bounds
        flow.view.autoresizingMask = [.width, .height]
        flow.view.translatesAutoresizingMaskIntoConstraints = true
        container.addSubview(flow.view)
        
        flowController = flow
        flowController?.analyzeString("")

        controlChangeObserver = NotificationCenter.default.addObserver(forName: NSControl.textDidChangeNotification,
                                                                       object: expressionField,
                                                                       queue: .main,
                                                                       using: { [weak self] _ in
                                                                        let text = self?.expressionField?.stringValue ?? ""
                                                                        self?.flowController?.analyzeString(text)
        })
    }
    
    func analyzerViewController(_ analyzer: AnalyzerViewController, wantsHighlightedRanges ranges: Array<Range<Int>>) {
        highlightRanges(ranges, isError: false)
    }
    
    func analyzerViewController(_ analyzer: AnalyzerViewController, wantsErrorPresented error: MathParserError?) {
        guard let error = error else {
            errorLabel?.stringValue = "No error"
            return
        }
        
        highlightRanges([error.range], isError: true)
        
        let msg: String
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
        errorLabel?.stringValue = msg
    }
    
    private func highlightRanges(_ ranges: Array<Range<Int>>, isError: Bool) {
        let string = expressionField?.stringValue ?? ""
        guard let attributed = expressionField?.attributedStringValue.mutableCopy() as? NSMutableAttributedString else { return }
        
        let wholeRange = NSRange(location: 0, length: attributed.length)
        attributed.setAttributes([.foregroundColor: NSColor.textColor], range: wholeRange)
        
        let color = isError ? NSColor.red : NSColor.systemPurple
        
        for range in ranges {
            let lower = string.index(string.startIndex, offsetBy: range.lowerBound)
            let upper = string.index(string.startIndex, offsetBy: range.upperBound)
            
            let nsRange = NSRange(lower ..< upper, in: string)
            attributed.setAttributes([.foregroundColor: color], range: nsRange)
            
            if range.isEmpty {
                // something needs to be "inserted" into the string
            } else {
                // something in the string is invalid
            }
        }
        expressionField?.attributedStringValue = attributed
    }
}
