//
//  Double.swift
//  DDMathParser
//
//  Created by Dave DeLong on 9/5/15.
//
//

import Foundation

internal extension Int {
    
    static let largestSupportedIntegerFactorial: Int = {
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
            // it's a factorial of an integer
            
            if self <= Double(Int.largestSupportedIntegerFactorial) {
                // it's a factorial of an integer representable as an Int
                let arg1Int = Int(self)
                return Double((1...arg1Int).reduce(1, *))
            } else if self < Double(Int.max) {
                // it's a factorial of an integer NOT representable as an Int
                var result = 1.0
                for i in 2 ..< Int(self) {
                    result *= Double(i)
                }
                return result
            }
        }
        return tgamma(self+1)
    }
    
}
