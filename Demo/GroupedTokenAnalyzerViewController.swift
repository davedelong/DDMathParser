//
//  GroupedTokenAnalyzerViewController.swift
//  Demo
//
//  Created by Dave DeLong on 11/21/17.
//

import Cocoa
import MathParser

class GroupedTokenAnalyzerViewController: AnalyzerViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    @IBOutlet var tokenTree: NSOutlineView?
    
    var groupedToken: GroupedToken?
    
    override init() {
        super.init()
        title = "Grouped"
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func analyzeString(_ string: String) {
        let grouper = TokenGrouper(string: string)
        do {
            groupedToken = try grouper.group()
        } catch let e as MathParserError {
            groupedToken = nil
            analyzerDelegate?.analyzerViewController(self, wantsErrorPresented: e)
        } catch let other {
            fatalError("Unknown error grouping expression: \(other)")
        }
        tokenTree?.reloadItem(nil, reloadChildren: true)
        tokenTree?.expandItem(nil, expandChildren: true)
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return groupedToken == nil ? 0 : 1
        }
        var maybeToken = item as? GroupedToken
        maybeToken = maybeToken ?? groupedToken
        guard let token = maybeToken else { return 0 }
        
        switch token.kind {
            case .function(_, let args): return args.count
            case .group(let args): return args.count
            default: return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil, let t = groupedToken { return t }
        guard let token = item as? GroupedToken else { fatalError("should only have GroupedTokens") }
        switch token.kind {
            case .function(_, let arguments): return arguments[index]
            case .group(let arguments): return arguments[index]
            default: fatalError("only functions and groups have children")
        }
        
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if item == nil { return "<root>"}
        guard let token = item as? GroupedToken else { fatalError("should only have GroupedToken") }
        let info: String
        switch token.kind {
            case .function(let f, let args):
                let argInfo = args.count == 1 ? "1 argument" : "\(args.count) arguments"
                info = "\(f)(\(argInfo))"
            case .group(let args):
                let argInfo = args.count == 1 ? "1 argument" : "\(args.count) arguments"
                info = "Group: (\(argInfo))"
            case .number(let d): info = "Number: \(d)"
            case .variable(let v): info = "Variable: \(v)"
            case .operator(let o): info = "Operator: \(o)"
        }
        
        return "\(info) - range: \(token.range)"
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let row = tokenTree?.selectedRow ?? -1
        
        if row >= 0 {
            guard let item = tokenTree?.item(atRow: row) else { fatalError("missing item at row \(row)") }
            guard let token = item as? GroupedToken else { fatalError("only GroupedTokens should be in the tree") }
            
            analyzerDelegate?.analyzerViewController(self, wantsHighlightedRanges: [token.range])
        } else {
            // unhighlight everything in the textfield
            analyzerDelegate?.analyzerViewController(self, wantsHighlightedRanges: [])
        }
    }
}
