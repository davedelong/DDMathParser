//
//  Either.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

internal enum Either<T, E: Error> {
    case value(T)
    case error(E)
    
    var value: T? {
        switch self {
            case .value(let v): return v
            default: return nil
        }
    }
    
    var error: E? {
        switch self {
            case .error(let e): return e
            default: return nil
        }
    }
}
