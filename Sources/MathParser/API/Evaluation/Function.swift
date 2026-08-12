//
//  Function.swift
//  DDMathParser
//
//  Created by Dave DeLong on 9/17/15.
//
//

import Foundation

public struct Function: Sendable {
    
    public typealias Body = @Sendable (EvaluationState) throws(MathParserError) -> Double
    
    public var names: Set<String>
    public let body: Body
    
    public init(name: String, body: @escaping Body) {
        self.init(names: [name], body: body)
    }
    
    public init(names: Set<String>, body: @escaping Body) {
        self.names = names
        self.body = body
    }
}
