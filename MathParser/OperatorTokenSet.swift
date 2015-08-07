//
//  OperatorTokenSet.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import Foundation

internal struct OperatorTokenSet {
    private let characters: Set<Character>
    private let tokens: Set<String>
    
    init(tokens: Array<String>) {
        var characters = Set<Character>()
        var tokens = Set<String>()
        
        for token in tokens {
            let lower = token.lowercaseString
            
            tokens.insert(token)
            tokens.insert(lower)
            
            characters.unionInPlace(token.characters)
            characters.unionInPlace(lower.characters)
        }
        
        self.characters = characters
        self.tokens = tokens
    }
    
    func isOperatorCharacter(c: Character) -> Bool {
        if c.isAlphabetic { return false }
        return characters.contains(c)
    }
    
    func isOperatorToken(s: String) -> Bool {
        return tokens.contains(s)
    }
    
    func hasOperatorWithPrefix(s: String) -> Bool {
        let matching = tokens.filter { $0.hasPrefix(s) }
        return !matching.isEmpty
    }
    
}
