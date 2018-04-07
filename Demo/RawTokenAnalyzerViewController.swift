//
//  RawTokenAnalysisViewController.swift
//  Demo
//
//  Created by Dave DeLong on 11/21/17.
//

import Cocoa
import MathParser

class RawTokenAnalyzerViewController: AnalyzerViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet var tokenList: NSTableView?
    
    var tokens = Array<RawToken>()
    
    override init() {
        super.init()
        title = "Raw"
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tokenList?.reloadData()
    }
    
    override func analyzeString(_ string: String) {
        let tokenizer = Tokenizer(string: string)
        do {
            tokens = try tokenizer.tokenize()
        } catch let e as MathParserError {
            tokens = []
            analyzerDelegate?.analyzerViewController(self, wantsErrorPresented: e)
        } catch let other {
            fatalError("Unknown error parsing expression: \(other)")
        }
        tokenList?.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tokens.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let token = tokens[row]
        return "\(token) - \"\(token.string)\" - range: \(token.range)"
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tokenList?.selectedRow ?? -1
        let ranges = (row >= 0) ? [tokens[row].range] : []
        
        analyzerDelegate?.analyzerViewController(self, wantsHighlightedRanges: ranges)
    }
}
