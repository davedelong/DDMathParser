//
//  PeekingGenerator.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/14/15.
//
//

import Foundation

protocol PeekingGeneratorType: IteratorProtocol {
    func peek() -> Element?
}

internal class PeekingGenerator<G: IteratorProtocol>: PeekingGeneratorType {
    typealias Element = G.Element
    
    private var generator: G
    private var peekBuffer = Array<Element>()
    
    init(generator: G) {
        self.generator = generator
    }
    
    func next() -> Element? {
        if let n = peekBuffer.first {
            peekBuffer.removeFirst()
            return n
        }
        
        return generator.next()
    }
    
    func peek() -> Element? {
        if let p = peekBuffer.first { return p }
        
        if let p = generator.next() {
            peekBuffer.append(p)
            return p
        }
        
        return nil
    }
}
