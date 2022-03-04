//
//  File.swift
//  
//
//  Created by Dave DeLong on 8/7/21.
//

import SwiftUI
import MathParser

@available(macOS 11.0, *)
struct ResolvedTokens: View {
    
    @ObservedObject var analyzer: Analyzer
    @State var selection: ResolvedToken?
    
    var body: some View {
        List(analyzer.resolvedTokens, id: \.self, selection: $selection) { token in
            Text(tokenDescription(token)).tag(token)
        }
        .tabItem { Text("Resolved") }
    }
    
    private func tokenDescription(_ token: ResolvedToken) -> String {
        let kind: String
        switch token.kind {
            case .identifier(_): kind = "Identifier"
            case .number(_): kind = "Number"
            case .operator(_): kind = "Operator"
            case .variable(_): kind = "Variable"
        }
        
        return "\(kind) - \"\(token.string)\" - range: \(token.range)"
    }
}

