//
//  File.swift
//  
//
//  Created by Dave DeLong on 8/7/21.
//

import SwiftUI
import MathParser

@available(macOS 11.0, *)
struct Expressions: View {
    
    @ObservedObject var analyzer: Analyzer
    @State var selection: RawToken?
    
    private var expressions: Array<Expression> {
        if let e = analyzer.expression { return [e] }
        return []
    }
    
    var body: some View {
        List(expressions, children: \.children) { expression in
            Text(expressionDescription(expression))
        }
        .tabItem { Text("Expression") }
    }
    
    private func expressionDescription(_ expression: Expression) -> String {
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
}

extension Expression: Identifiable {
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
    var children: Array<Expression>? {
        switch kind {
            case .number: return nil
            case .variable: return nil
            case .function(_, let children): return children
        }
    }
}
