//
//  RawToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/12/15.
//
//

import Foundation

internal protocol RawToken {
    var string: String { get }
    var range: Range<String.Index> { get }
}

internal struct HexNumberToken: RawToken {
    let string: String
    let range: Range<String.Index>
}

internal struct OctalNumberToken: RawToken {
    let string: String
    let range: Range<String.Index>
}

internal struct DecimalNumberToken: RawToken {
    let string: String
    let range: Range<String.Index>
}

internal struct FractionNumberToken: RawToken {
    let string: String
    let range: Range<String.Index>
}

internal struct LocalizedNumberToken: RawToken {
    let string: String
    let range: Range<String.Index>
}

internal struct ExponentToken: RawToken {
    let string: String
    let range: Range<String.Index>
}

internal struct VariableToken: RawToken {
    let string: String
    let range: Range<String.Index>
}

internal struct OperatorToken: RawToken {
    let string: String
    let range: Range<String.Index>
}

internal struct IdentifierToken: RawToken {
    let string: String
    let range: Range<String.Index>
}
