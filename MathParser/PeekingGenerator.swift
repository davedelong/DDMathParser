//
//  PeekingGenerator.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/14/15.
//
//

import Foundation

protocol PeekingGeneratorType: GeneratorType {
    func prev() -> Element?
    func peek() -> Element?
}

internal class PeekingGenerator<G: GeneratorType>: PeekingGeneratorType {
    typealias Element = G.Element
    
    private var generator: G
    private var peekBuffer = Array<Element>()
    private var previous: Element?
    
    init(generator: G) {
        self.generator = generator
    }
    
    func prev() -> Element? {
        return previous
    }
    
    func next() -> Element? {
        if let n = peekBuffer.first {
            peekBuffer.removeFirst()
            previous = n
            return n
        }
        
        if let n = generator.next() {
            previous = n
            return n
        }
        
        return nil
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
