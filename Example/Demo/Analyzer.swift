//
//  File.swift
//  
//
//  Created by Dave DeLong on 8/7/21.
//

import SwiftUI
import MathParser

@available(macOS 11.0, *)
class Analyzer: ObservableObject {
    
    var rawExpression = "" {
        willSet { objectWillChange.send() }
        didSet { analyze() }
    }
    
    private(set) var error: MathParserError?
    
    private(set) var rawTokens: Array<RawToken> = []
    private(set) var resolvedTokens: Array<ResolvedToken> = []
    private(set) var groupedToken: GroupedToken?
    private(set) var expression: Expression?
    private(set) var variables: Array<String> = []
    
    private func analyze() {
        error = nil
        rawTokens = []
        resolvedTokens = []
        groupedToken = nil
        expression = nil
        
        do {
            let tokenizer = Tokenizer(string: rawExpression)
            rawTokens = try tokenizer.tokenize()
            
            // this is not terribly efficient,
            // because each layer is re-doing the work
            // of the previous layer
            let resolver = TokenResolver(string: rawExpression)
            resolvedTokens = try resolver.resolve()
            
            let grouper = TokenGrouper(string: rawExpression)
            groupedToken = try grouper.group()
            
            expression = try Expression(string: rawExpression)
            
            var variables = Set<String>()
            func collect(_ expression: Expression) {
                switch expression.kind {
                    case .number(_): break
                    case .variable(let v): variables.insert(v)
                    case .function(_, let children): children.forEach { collect($0) }
                }
            }
            collect(expression!)
            self.variables = variables.sorted(by: <)
            
        } catch let e as MathParserError {
            error = e
        } catch let other {
            fatalError("Unreachable: Unknown error parsing expression \(rawExpression): \(other)")
        }
        
    }
    
}
