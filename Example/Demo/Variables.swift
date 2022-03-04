//
//  File.swift
//  
//
//  Created by Dave DeLong on 8/9/21.
//

import SwiftUI
import MathParser

@available(macOS 11.0, *)
struct Variables: View {
    
    @ObservedObject var analyzer: Analyzer
    @State var variables = Dictionary<String, Double>()
    
    private var evaluatedValue: Double {
        return (try? analyzer.expression?.substitutionValue(using: .default, substitutions: variables)) ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Value: \(evaluatedValue)")
            GroupBox(label: Text("Variables")) {
                Form {
                    ForEach(analyzer.variables, id: \.self) { v in
                        TextField(v, value: self.binding(for: v), formatter: formatter)
                    }
                }
            }
        }
        .tabItem { Text("Variables") }
    }
    
    private func binding(for variable: String) -> Binding<Double> {
        return Binding(get: {
            self.variables[variable] ?? 0
        }, set: {
            self.variables[variable] = $0
        })
    }
}

private let formatter: NumberFormatter = {
    let n = NumberFormatter()
    n.numberStyle = .decimal
    return n
}()
