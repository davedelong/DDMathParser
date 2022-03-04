//
//  File.swift
//  
//
//  Created by Dave DeLong on 8/7/21.
//

import SwiftUI
import MathParser

@available(macOS 11.0, *)
struct GroupedTokens: View {
    
    @ObservedObject var analyzer: Analyzer
    @State var selection: RawToken?
    
    private var groupedTokens: Array<GroupedToken> {
        if let t = analyzer.groupedToken { return [t] }
        return []
    }
    
    var body: some View {
        List(groupedTokens, children: \.children) { token in
            Text(tokenDescription(token))
        }
        .tabItem { Text("Groups") }
    }
    
    private func tokenDescription(_ token: GroupedToken) -> String {
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
}

extension GroupedToken: Identifiable {
    public var id: Range<String.Index> { self.range }
    var children: Array<GroupedToken>? {
        switch self.kind {
            case .number(_): return nil
            case .variable(_): return nil
            case .operator(_): return nil
            case .function(_, let children): return children
            case .group(let children): return children
        }
    }
}
