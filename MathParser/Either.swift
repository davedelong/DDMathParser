//
//  Either.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

internal enum Either<T, E: ErrorType> {
    case Value(T)
    case Error(E)
    
    var value: T? {
        switch self {
            case .Value(let v): return v
            default: return nil
        }
    }
    
    var error: E? {
        switch self {
            case .Error(let e): return e
            default: return nil
        }
    }
    
    var hasValue: Bool { return value != nil }
    var hasError: Bool { return error != nil }
}
