//
//  ExpressionAnalyzerViewController.swift
//  Demo
//
//  Created by Dave DeLong on 11/21/17.
//

import Cocoa
import MathParser

class ExpressionAnalyzerViewController: AnalyzerViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    @IBOutlet var expressionTree: NSOutlineView?
    
    var parsedExpression: Expression?
    
    override init() {
        super.init()
        title = "Expression"
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func analyzeString(_ string: String) {
        do {
            parsedExpression = try Expression(string: string)
        } catch let e as MathParserError {
            parsedExpression = nil
            analyzerDelegate?.analyzerViewController(self, wantsErrorPresented: e)
        } catch let other {
            fatalError("Unknown error parsing expression: \(other)")
        }
        expressionTree?.reloadItem(nil, reloadChildren: true)
        expressionTree?.expandItem(nil, expandChildren: true)
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return parsedExpression == nil ? 0 : 1
        }
        var maybeExpression = item as? Expression
        maybeExpression = maybeExpression ?? parsedExpression
        guard let expression = maybeExpression else { return 0 }
        
        switch expression.kind {
            case .function(_, let arguments): return arguments.count
            default: return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil, let e = parsedExpression { return e }
        guard let expression = item as? Expression else { fatalError("should only have Expressions") }
        switch expression.kind {
            case .function(_, let arguments): return arguments[index]
            default: fatalError("only argument functions have children")
        }
        
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if item == nil { return "<root>"}
        guard let expression = item as? Expression else { fatalError("should only have Expressions") }
        let info: String
        switch expression.kind {
            case .number(let d): info = "Number: \(d)"
            case .variable(let v): info = "Variable: \(v)"
            case .function(let f, let args):
                let argInfo = args.count == 1 ? "1 argument" : "\(args.count) arguments"
                info = "\(f)(\(argInfo))"
        }
        return "\(info) - range: \(expression.range)"
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let row = expressionTree?.selectedRow ?? -1
        
        if row >= 0 {
            guard let item = expressionTree?.item(atRow: row) else { fatalError("missing item at row \(row)") }
            guard let expression = item as? Expression else { fatalError("only expressions should be in the tree") }
            
            analyzerDelegate?.analyzerViewController(self, wantsHighlightedRanges: [expression.range])
        } else {
            // unhighlight everything in the textfield
            analyzerDelegate?.analyzerViewController(self, wantsHighlightedRanges: [])
        }
    }
}
