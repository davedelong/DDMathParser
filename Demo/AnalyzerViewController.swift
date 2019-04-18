//
//  AnalyzerViewController.swift
//  Demo
//
//  Created by Dave DeLong on 11/21/17.
//

import Cocoa
import MathParser

protocol AnalyzerDelegate: class {
    
    func analyzerViewController(_ analyzer: AnalyzerViewController, wantsHighlightedRanges ranges: Array<Range<Int>>)
    func analyzerViewController(_ analyzer: AnalyzerViewController, wantsErrorPresented error: MathParserError?)
}

class AnalyzerViewController: NSViewController {
    
    weak var analyzerDelegate: AnalyzerDelegate?
    
    init() {
        let nibName = NSNib.Name("\(type(of: self))")
        let bundle = Bundle(for: type(of: self))
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func analyzeString(_ string: String) {
        fatalError("Subclasses must override \(#function)")
    }

}
