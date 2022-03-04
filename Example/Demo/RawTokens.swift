//
//  File.swift
//  
//
//  Created by Dave DeLong on 8/7/21.
//

import SwiftUI
import MathParser

@available(macOS 11.0, *)
struct RawTokens: View {
    
    @ObservedObject var analyzer: Analyzer
    @State var selection: RawToken?
    
    var body: some View {
        List(analyzer.rawTokens, id: \.self, selection: $selection) { token in
            Text(tokenDescription(token)).tag(token)
        }
        .tabItem { Text("Raw") }
    }
    
    private func tokenDescription(_ token: RawToken) -> String {
        return "\(token) - \"\(token.string)\" - range: \(token.range)"
    }
}
