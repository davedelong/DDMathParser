//
//  String.CharacterView.Index.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

internal extension String.CharacterView.Index {
    func extendedBy(delta: UInt) -> String.CharacterView.Index {
        var index = self
        for _ in 0 ..< delta {
            index = index.successor()
        }
        return index
    }
    
    func distanceTo(other: String.CharacterView.Index) -> Int {
        if self > other {
            return -other.distanceTo(self)
        }
        
        var d = 0
        var next = self
        while next != other {
            next = next.successor()
            d++
        }
        
        return d
    }
}
