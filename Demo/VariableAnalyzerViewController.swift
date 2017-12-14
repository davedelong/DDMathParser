//
//  VariableAnalyzerViewController.swift
//  Demo
//
//  Created by Dave DeLong on 12/14/17.
//

import Cocoa
import MathParser

extension Expression {
    var variableName: String? {
        guard case .variable(let v) = kind else { return nil }
        return v
    }
}

class VariableAnalyzerViewController: AnalyzerViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var parsedExpression: Expression?
    
    var variableExpressions = Dictionary<String, Array<Expression>>()
    var variables = Array<String>()
    var values = Dictionary<String, Double>()
    
    @IBOutlet var tableView: NSTableView?
    @IBOutlet var resultLabel: NSTextField?
    
    override init() {
        super.init()
        title = "Evaluation"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func analyzeString(_ string: String) {
        resultLabel?.stringValue = ""
        
        do {
            let e = try Expression(string: string)
            parsedExpression = e
            
            let collected = collectVariables(from: e)
            
            variableExpressions = Dictionary(grouping: collected, by: { $0.variableName! })
            variables = variableExpressions.keys.sorted()
            
            tableView?.reloadData()
            reevaluateExpression()
            
        } catch let e as MathParserError {
            parsedExpression = nil
            analyzerDelegate?.analyzerViewController(self, wantsErrorPresented: e)
        } catch let other {
            fatalError("Unknown error parsing expression: \(other)")
        }
    }
    
    func reevaluateExpression() {
        guard let expression = parsedExpression else { return }
        analyzerDelegate?.analyzerViewController(self, wantsErrorPresented: nil)
        
        let evaluator = Evaluator.default
        do {
            let result = try evaluator.evaluate(expression, substitutions: values)
            resultLabel?.stringValue = "\(result)"
        } catch let e as MathParserError {
            analyzerDelegate?.analyzerViewController(self, wantsErrorPresented: e)
        } catch let e {
            fatalError("Unknown error evaluating expression: \(e)")
        }
    }
    
    func collectVariables(from expression: Expression) -> Array<Expression> {
        var variables = Array<Expression>()
        
        switch expression.kind {
            case .variable(_):
                variables.append(expression)
            case .function(_, let args):
                let subVariables = args.flatMap { collectVariables(from: $0) }
                variables.append(contentsOf: subVariables)
            default:
                break
        }
        
        return variables
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return variables.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row >= 0 && row < variables.count else { return nil }
        let name = variables[row]
        
        if tableColumn?.identifier.rawValue == "variable" { return name }
        return values[name]
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return tableColumn?.identifier.rawValue != "variable"
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard row >= 0 && row < variables.count else { return }
        let value = object as? Double
        let name = variables[row]
        values[name] = value
        reevaluateExpression()
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let row = tableView?.selectedRow, row >= 0 && row < variables.count else {
            analyzerDelegate?.analyzerViewController(self, wantsHighlightedRanges: [])
            return
        }
        let name = variables[row]
        let expressions = variableExpressions[name] ?? []
        let ranges = expressions.map { $0.range }
        analyzerDelegate?.analyzerViewController(self, wantsHighlightedRanges: ranges)
    }
    
}
