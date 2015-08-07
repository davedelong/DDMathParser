//
//  Either.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

public enum Either<T, E: ErrorType> {
    case Value(T)
    case Error(E)
    
    public var value: T? {
        switch self {
            case .Value(let v): return v
            default: return nil
        }
    }
    
    public var error: E? {
        switch self {
        case .Error(let e): return e
        default: return nil
        }
    }
}
