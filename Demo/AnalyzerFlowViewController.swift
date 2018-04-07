//
//  AnalyzerFlowViewController.swift
//  Demo
//
//  Created by Dave DeLong on 11/21/17.
//

import Cocoa
import MathParser

class AnalyzerFlowViewController: AnalyzerViewController, AnalyzerDelegate, NSTabViewDelegate {
    
    @IBOutlet var tabView: NSTabView?
    
    private var analyzers = Array<AnalyzerViewController>()
    private var currentAnalyzedString = ""
    private var currentAnalyzer: AnalyzerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        while let item = tabView?.tabViewItems.first {
            tabView?.removeTabViewItem(item)
        }
        
        analyzers = [
            RawTokenAnalyzerViewController(),
            ResolvedTokenAnalyzerViewController(),
            GroupedTokenAnalyzerViewController(),
            ExpressionAnalyzerViewController(),
            VariableAnalyzerViewController()
        ]
        
        for analyzer in analyzers {
            analyzer.analyzerDelegate = self
            let item = NSTabViewItem(viewController: analyzer)
            tabView?.addTabViewItem(item)
        }
        
        tabView?.selectTabViewItem(at: 0)
        handleSwitchToAnalyzer(analyzers[0])
    }
    
    override func analyzeString(_ string: String) {
        currentAnalyzedString = string
        analyzerDelegate?.analyzerViewController(self, wantsHighlightedRanges: [])
        analyzerDelegate?.analyzerViewController(self, wantsErrorPresented: nil)
        currentAnalyzer?.analyzeString(string)
    }
    
    private func handleSwitchToAnalyzer(_ analyzer: AnalyzerViewController) {
        currentAnalyzer = analyzer
        analyzerDelegate?.analyzerViewController(self, wantsHighlightedRanges: [])
        analyzerDelegate?.analyzerViewController(self, wantsErrorPresented: nil)
        analyzer.analyzeString(currentAnalyzedString)
    }
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        guard let vc = tabViewItem?.viewController else { return }
        guard let analyzer = vc as? AnalyzerViewController else { return }
        handleSwitchToAnalyzer(analyzer)
    }
    
    func analyzerViewController(_ analyzer: AnalyzerViewController, wantsHighlightedRanges ranges: Array<Range<Int>>) {
        guard analyzer == currentAnalyzer else { return }
        analyzerDelegate?.analyzerViewController(self, wantsHighlightedRanges: ranges)
    }
    
    func analyzerViewController(_ analyzer: AnalyzerViewController, wantsErrorPresented error: MathParserError?) {
        guard analyzer == currentAnalyzer else { return }
        analyzerDelegate?.analyzerViewController(self, wantsErrorPresented: error)
    }
    
}
