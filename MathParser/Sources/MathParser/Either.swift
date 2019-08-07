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
}
