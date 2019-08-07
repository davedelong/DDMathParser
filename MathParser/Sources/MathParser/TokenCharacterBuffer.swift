//
//  TokenCharacterBuffer.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

internal final class TokenCharacterBuffer {
    private let characters: Array<Character>
    private let lowercaseCharacters: Array<Character>
    private(set) var currentIndex: Int
    
    init(string: String) {
        characters = Array(string)
        lowercaseCharacters = Array(string.lowercased())
        
        currentIndex = 0
    }
    
    var isAtEnd: Bool {
        return currentIndex >= characters.count
    }
    
    func resetTo(_ index: Int) {
        currentIndex = index
    }
    
    func peekNext(_ delta: Int = 0, lowercase: Bool = false) -> Character? {
        guard delta >= 0 else {
            fatalError("Cannot peek into the past")
        }
        let chars = lowercase ? lowercaseCharacters : characters
        
        let index = currentIndex + delta
        guard index < chars.count else { return nil }
        return chars[index]
    }
    
    func consume(_ delta: Int = 1) {
        guard delta > 0 else {
            fatalError("Cannot consume less than one character")
        }
        currentIndex = currentIndex + delta
    }
    
    subscript (i: Int) -> Character {
        return characters[i]
    }
    
    subscript (r: Range<Int>) -> String {
        return String(characters[r])
    }
}
