//
//  TokenCharacterBuffer.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

internal final class TokenCharacterBuffer {
    private let string: String
    
    var startIndex: String.Index { string.startIndex }
    private(set) var currentIndex: String.Index
    
    init(string: String) {
        self.string = string
        self.currentIndex = string.startIndex
    }
    
    var isAtEnd: Bool {
        return currentIndex >= string.endIndex
    }
    
    func resetTo(_ index: String.Index) {
        currentIndex = index
    }
    
    func peekNext(_ delta: Int = 0, lowercase: Bool = false) -> Character? {
        guard delta >= 0 else {
            fatalError("Cannot peek into the past")
        }
        
        let index = string.index(currentIndex, offsetBy: delta)
        guard index < string.endIndex else { return nil }
        var character = string[index]
        if lowercase == true {
            character = character.lowercased().first ?? character
        }
        return character
    }
    
    func consume(_ delta: Int = 1) {
        guard delta > 0 else {
            fatalError("Cannot consume less than one character")
        }
        currentIndex = string.index(currentIndex, offsetBy: delta)
    }
    
    func currentDistance(from index: String.Index) -> Int {
        return string.distance(from: index, to: currentIndex)
    }
    
    subscript (i: String.Index) -> Character {
        return string[i]
    }
    
    subscript (r: Range<String.Index>) -> String {
        return String(string[r])
    }
}
