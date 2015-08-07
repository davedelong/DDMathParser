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
    private(set) var currentIndex: String.CharacterView.Index
    
    init(string: String) {
        characters = string.characters
        lowercaseCharacters = string.lowercaseString.characters
        
        currentIndex = characters.startIndex
    }
    
    var isAtEnd: Bool {
        return currentIndex >= characters.endIndex
    }
    
    func resetTo(index: String.CharacterView.Index) {
        currentIndex = index
    }
    
    func next(lowercase: Bool = false) -> Character? {
        let chars = lowercase ? lowercaseCharacters : characters
        
        guard currentIndex < chars.endIndex else { return nil }
        let character = chars[currentIndex]
        currentIndex++
        return character
    }
    
    func peekNext(delta: UInt = 0, lowercase: Bool = false) -> Character? {
        let chars = lowercase ? lowercaseCharacters : characters
        
        let index = currentIndex.extendedBy(delta)
        guard index < chars.endIndex else { return nil }
        return chars[currentIndex]
    }
    
    func consume(delta: UInt = 1) {
        assert(delta > 0, "Cannot consume zero characters")
        currentIndex = currentIndex.extendedBy(delta)
    }
    
    subscript (i: String.CharacterView.Index) -> Character {
        return characters[i]
    }
    
    subscript (r: Range<String.CharacterView.Index>) -> String {
        return String(characters[r])
    }
}
