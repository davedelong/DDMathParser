//
//  Double.swift
//  DDMathParser
//
//  Created by Dave DeLong on 9/5/15.
//
//

import Foundation

internal extension Int {
    
    static let largestIntegerFactorial: Int = {
        var n = Int.max
        var i = 2
        while i < n {
            n /= i
            i += 1
        }
        return i - 1
    }()
    
}

internal extension Double {
    
    func factorial() -> Double {
        if Darwin.floor(self) == self && self > 1 {
            // it's an integer
            let arg1Int = Int(self)
            
            if arg1Int <= Int.largestIntegerFactorial {
                return Double((1...arg1Int).reduce(1, *))
            } else {
                // but it can't be represented in a word-sized Int
                var result = 1.0
                for i in 2 ... arg1Int {
                    result *= Double(i)
                }
                return result
            }
        } else {
            return tgamma(self+1)
        }
    }
    
}
