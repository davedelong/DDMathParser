//
//  TokenCharacterBuffer.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

internal class TokenCharacterBuffer {
    private let characters: String.CharacterView
    private let lowercaseCharacters: String.CharacterView
    private(set) var currentIndex: String.Index
    
    init(string: String) {
        characters = string.characters
        lowercaseCharacters = string.lowercaseString.characters
        
        currentIndex = characters.startIndex
    }
    
    var isAtEnd: Bool {
        return currentIndex >= characters.endIndex
    }
    
    func resetTo(index: String.Index) {
        currentIndex = index
    }
    
    func peekNext(delta: Int = 0, lowercase: Bool = false) -> Character? {
        guard delta >= 0 else {
            fatalError("Cannot peek into the past")
        }
        let chars = lowercase ? lowercaseCharacters : characters
        
        let index = currentIndex.advancedBy(delta)
        guard index < chars.endIndex else { return nil }
        return chars[index]
    }
    
    func consume(delta: Int = 1) {
        guard delta > 0 else {
            fatalError("Cannot consume less than one character")
        }
        currentIndex = currentIndex.advancedBy(delta)
    }
    
    subscript (i: String.Index) -> Character {
        return characters[i]
    }
    
    subscript (r: Range<String.Index>) -> String {
        return String(characters[r])
    }
}
