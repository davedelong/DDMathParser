//
//  Deprecations.swift
//  MathParser
//
//  Created by Dave DeLong on 4/18/19.
//

import Foundation

public extension Tokenizer {
    @available(*, deprecated, renamed: "init(string:configuration:)")
    init(string: String, operatorSet: OperatorSet = OperatorSet.default, locale: Locale? = nil) {
        var c = Configuration.default
        c.operatorSet = operatorSet
        c.locale = locale
        self.init(string: string, configuration: c)
    }
}

@available(*, deprecated, message: "Use Configuration instead.")
public struct TokenResolverOptions: OptionSet {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let none = TokenResolverOptions(rawValue: 0)
    public static let allowArgumentlessFunctions = TokenResolverOptions(rawValue: 1 << 0)
    public static let allowImplicitMultiplication = TokenResolverOptions(rawValue: 1 << 1)
    public static let useHighPrecedenceImplicitMultiplication = TokenResolverOptions(rawValue: 1 << 2)
    
    public static let `default`: TokenResolverOptions = [.allowArgumentlessFunctions, .allowImplicitMultiplication, .useHighPrecedenceImplicitMultiplication]
}

public extension TokenResolver {
    @available(*, deprecated, renamed: "init(tokenizer:)")
    init(tokenizer: Tokenizer, options: TokenResolverOptions = TokenResolverOptions.default) {
        self.init(tokenizer: tokenizer)
    }
}

public extension Expression {
    @available(*, deprecated, renamed: "init(string:configuration:)")
    convenience init(string: String, operatorSet: OperatorSet = OperatorSet.default, options: TokenResolverOptions = TokenResolverOptions.default, locale: Locale? = nil) throws {
        var c = Configuration()
        c.operatorSet = operatorSet
        c.allowArgumentlessFunctions = options.contains(.allowArgumentlessFunctions)
        c.allowImplicitMultiplication = options.contains(.allowImplicitMultiplication)
        c.useHighPrecedenceImplicitMultiplication = options.contains(.useHighPrecedenceImplicitMultiplication)
        c.locale = locale
        try self.init(string: string, configuration: c)
    }
}
