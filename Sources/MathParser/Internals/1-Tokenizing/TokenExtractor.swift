//
//  TokenExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

internal protocol TokenExtractor {
    
    var specialCharacters: Set<Character> { get }
    func matchesPreconditions(_ buffer: TokenCharacterBuffer, configuration: Configuration) -> Bool
    func extract(_ buffer: TokenCharacterBuffer, configuration: Configuration) -> Result<RawToken, MathParserError>
    
}
