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
    private(set) var currentIndex: String.CharacterView.Index
    
    init(string: String) {
        characters = string.characters
        currentIndex = characters.startIndex
    }
    
    var isAtEnd: Bool {
        return currentIndex >= characters.endIndex
    }
    
    func resetTo(index: String.CharacterView.Index) {
        currentIndex = index
    }
    
    func next() -> Character? {
        guard currentIndex < characters.endIndex else { return nil }
        let character = characters[currentIndex]
        currentIndex++
        return character
    }
    
    func peekNext(delta: UInt = 0) -> Character? {
        let index = currentIndex.extendedBy(delta)
        guard index < characters.endIndex else { return nil }
        return characters[currentIndex]
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
