//
//  Character.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

internal extension Character {
    
    var isDigit: Bool {
        switch self {
            case "0"..."9": return true
            default: return false
        }
    }
    
    var isHexDigit: Bool {
        switch self {
            case "a"..."f": return true
            case "A"..."F": return true
            default: return isDigit
        }
    }
    
}
