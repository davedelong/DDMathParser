//
//  Configuration.swift
//  MathParser
//
//  Created by Dave DeLong on 4/18/19.
//

import Foundation

/// High-level options used when parsing expressions
///
/// The ``Configuration`` struct defines high-level options that are used when parsing mathematical expressions,
/// such as how implicit multiplication should work, what ``Foundation/Locale`` to use for localized numbers, and so on.
///
/// For details on how parsing works, see <doc:/internals/Tokenizing>.
public struct Configuration {
    
    /// The default ``Configuration`` value.
    public static let `default` = Configuration()
    
    /// The ``OperatorSet`` that will be used when parsing expressions.
    ///
    /// The default value is `.default`
    public var operatorSet: OperatorSet
    
    /// The ``Foundation/Locale`` to use for parsing localized numbers.
    ///
    /// The default value is `nil`, indicating that localized numbers are not supported.
    public var locale: Locale?
    
    /// Whether the parser should allow "empty" variable names.
    ///
    /// Variables are terms in an expression that either begin with `$` or are surrounded by double quotes `"..."`.
    /// An "empty" variable would be a `$` with no associated name, such as `1 + $`, or `2 * ""`. When evaluating
    /// such an expression, the ``Evaluator`` would look for a variable whose name is the empty string (`""`).
    /// Use this property to configure whether these kinds of variables should be allowed when parsing.
    ///
    /// The default value is `false`, indicating that zero-length variable names are not supported.
    public var allowZeroLengthVariables: Bool
    
    /// Whether the parser should "unescape" characters inside a quoted variable name.
    ///
    /// When a variable uses backslashes inside the quoted name, this option changes how that name is parsed.
    /// If this value is `true` and an expression contains the variable `"\"name\""`, then the variable name will be parsed as `"name"`.
    /// If this value is `false` and an expression contains the variable `"\"name\""`, then the variable name will be parsed as `\"name\"`.
    ///
    /// The default value is `true`, indicating that backslashes will be removed from variable names.
    public var unescapesQuotedVariables: Bool
    
    /// Whether the parser should allow functions that do not have an associated set of parentheses.
    ///
    /// When the parser finds the name of a function, it also looks for parentheses that indicate the arguments for the function.
    /// For example, in the expression `add(1, 2)`, the function is `add` and the arguments are `1` and `2`. Some functions do not
    /// accept arguments, such as various mathematical consants: `π` is implemented as a function that takes no arguments.
    ///
    /// This property controls whether the parser should automatically *insert* parentheses into the parsed expression, so that function names
    /// get interpreted as function calls. When this value is `true`, expressions like `e * π` get automatically transformed into `e() * π()`.
    ///
    /// The default value is `true`. It would be very unusual to change this value to `false`.
    public var allowArgumentlessFunctions: Bool
    
    /// Whether the parser should allow implicit multiplication.
    ///
    /// Some expressions read more fluently when the multiplication operator is omitted, such as `3x`. This gets parsed as two separate terms: `3` and `x`.
    /// When this value is `true`, the parser will automatically insert a multiplication operator between two such terms,
    /// so that it's equivalent to `3 * x`. When combined with ``Configuration/allowArgumentlessFunctions``, this will then be evaluated
    /// as `3 * x()`.
    ///
    /// The default value is `true`. It would be very unusual to change this value to `false`.
    public var allowImplicitMultiplication: Bool
    
    /// Whether the parser should evaluate implicit multiplication before other operators or not.
    ///
    /// An expression like `3x²` can be interpreted two different ways:
    /// 1. as `3 * x²` (example: when x = 2, this evaluates to `18`)
    /// 2. as `(3 * x)²` (example: when x = 2, this evaluates to `36`)
    ///
    /// When this value is `false`, implicit multiplication operates at the *same* precedence as normal (explicit) multiplication,
    /// providing the evaluation result shown in the first option.
    ///
    /// When this value is `true`, implicit multiplication operates at a *higher* precedence than almost all other operators, resulting
    /// in it getting evaluated before other operators (such as exponentiation), providing the evaluation result shown in the second option.
    ///
    /// The default value is `true`, indicating that implicit multiplication should evaluated before most other operators. Changing this to `false`
    /// may lead to some surprising and unexpected evaluations.
    public var useHighPrecedenceImplicitMultiplication: Bool
    
    /// Whether variables should be treated with case sensitivity or not.
    ///
    /// When this value is `true`, then variables that are spelled the same but differ only by their case are treated as distinct. For example,
    /// `$FOO` would be a *different* variable than `$foo`.
    ///
    /// When this value is `false`, then variables are treated as *case insensitive*, and `$FOO` would be considered the same variable as `$foo`.
    ///
    /// The default value is `true`, meaning variables that by differ by their case are considered distinct.
    public var caseSensitiveVariables: Bool
    
    /// Instantiate a new ``Configuration`` with all of the default values set.
    public init() {
        operatorSet = OperatorSet.default
        locale = nil
        
        allowZeroLengthVariables = false
        unescapesQuotedVariables = true
        
        allowArgumentlessFunctions = true
        allowImplicitMultiplication = true
        useHighPrecedenceImplicitMultiplication = true
        
        caseSensitiveVariables = true
    }
    
}
