//
//  RawToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/12/15.
//
//

import Foundation

public class RawToken {
    public let string: String
    public let range: Range<Int>
    
    public init(string: String, range: Range<Int>) {
        self.string = string
        self.range = range
    }
}

public class HexNumberToken: RawToken { }
public class OctalNumberToken: RawToken { }
public class DecimalNumberToken: RawToken { }
public class FractionNumberToken: RawToken { }
public class LocalizedNumberToken: RawToken { }
public class ExponentToken: RawToken { }
public class VariableToken: RawToken { }
public class OperatorToken: RawToken { }
public class IdentifierToken: RawToken { }
