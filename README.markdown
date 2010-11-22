# DDMathParser

You have an `NSString`.  You want an `NSNumber`.  Previously, you would have to rely on [abusing `NSPredicate`](http://tumblr.com/xqopow93r) to turn your string into an `NSExpression` that you could then evaluate.  However, this has a major flaw:  extending it to support functions that aren't built-in to `NSExpression` provided for some awkward syntax.  So if you really need `sin()`, you have to jump through some intricate hoops to get it.

You could also have used [`GCMathParser`](http://apptree.net/parser.htm).  This, however, isn't extensible at all.  So if you really needed a `stddev()` function, you're out of luck.

Thus, `DDMathParser`.  It is written to be identical to `NSExpression` in all the ways that matter (in fact, it actually uses `NSExpression` to evaluate many of its built-in functions), but with the major addition that you can define new functions as you need.

## Features

### Registering Functions

Registering new functions is easy.  You just need a block, a name, and the number of arguments the function accepts.  So for example:

    DDMathFunction function = ^ DDExpression* (NSArray * args, NSDictionary * variables, DDMathEvaluator * evaluator) {
      NSNumber * n = [[args objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
      NSNumber * result = [NSNumber numberWithDouble:[n doubleValue] * 42.0f];
      return [DDExpression numberExpressionWithNumber:result];
    };
    [[DDMathEvaluator sharedMathEvaluator] registerFunction:function forName:@"multiplyBy42" numberOfArguments:1];
    
    NSLog(@"%@", [[DDMathEvaluator sharedMathEvaluator] evaluateString:@"multiplyBy42(3)" withSubstitutions:nil]);  //logs "126"
    
You can also unregister added functions.  You cannot unregister built-in functions, nor can they be overridden.
    
Function names must begin with a letter, and can contain letters and digits.  Functions are case-insensitive.  (`mUlTiPlYbY42` is the same as `multiplyby42`)

Functions are registered with a specific instance of `DDMathEvaluator`.  The simplest approach is to register everything with the shared instance (`[DDMathEvaluator sharedMathEvaluator]`).  However, should you only need certain functions available in certain contexts, you can allocate and initialize any number of `DDMathEvaluator` objects.  All math evaluators recognize the built-in functions.
    
### Variables

If you don't know what the value of a particular term should be when the string is constructed, that's ok; simply use a variable:

    NSString * math = @"6 * $a";
    
Then when you figure out what the value is supposed to be, you can pass it along in the substitution dictionary:

    NSLog(@"%@", [[DDMathEvaluator sharedMathEvaluator] evaluateString:math withSubstitutions:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:7] forKey:@"a"]]); //logs "42"
    
Variables are denoted in the source string as beginning with `$` and can contain numbers or letters.  They are case sensitive.  (`$a` is not the same as `$A`)
    
### Associativity

By default, all binary operators are left associative.  That means if you give a string, such as `@"2 ** 3 ** 2"`, it will be parsed as `@"(2 ** 3) ** 2`, in order to maintain parity with `NSExpression`.

The exception to this is the power operator (`**`), which has its associativity determined at runtime.  The reason for this is that the power operator is supposed to be right associative, but is interpreted by `NSPredicate` as left associative ([rdar://problem/8692313](rdar://problem/8692313)).  `DDMathParser` performs a test to match the associativity used by `NSPredicate`.

If you want this operator to be parsed with specific associativity, you can do so like this:

    DDMathParser * parser = [DDMathParser mathParserWithString:@"2 ** 3 ** 2"];
    [parser setPowerAssociativity:DDMathParserAssociativityRight];
    DDExpression * e = [parser parsedExpression];
   
All binary operators can have their associativity changed this way.

### Operators

`DDMathEvaluator` recognizes all common mathematical operators:

- `+` - addition
- `-` - subtraction (also negation)
- `*` (or `x`) - multiplication
- `/` - division
- `%` - modulus
- `!` - factorial
- `&` - bitwise and
- `|` - bitwise or
- `^` - bitwise xor
- `~` - bitwise not
- `<<` - bitwise left shift
- `>>` - bitwise right shift

### Built-in functions

In addition to the functions defined by the operators above, the following functions are built in:

Functions that take > 1 parameter

- `sum()` - returns a sum of the passed parameters
- `count()` - returns the number of passed parameters
- `min()` - returns the minimum of the passed parameters
- `max()` - returns the maximum of the passed parameters
- `median()` - returns the median of the passed parameters
- `mode()` - returns the mode of the passed parameters
- `stddev()` - returns the standard deviation of the passed parameters

Functions that take 1 parameter:

- `sqrt()` - returns the square root of the passed parameter
- `log()` - returns the base 10 log of the passed parameter
- `ln()` - returns the base e log of the passed parameter
- `exp()` - returns e raised to the power of the passed parameter
- `ceil()` - returns the passed parameter rounded up
- `trunc()` - returns the passed parameter rounded up or down
- `floor()` - returns the passed parameter rounded down
- `onescomplement()` - returns the ones complement of the passed parameter
- `sin()` - returns the sine of the passed parameter (in radians)
- `cos()` - returns the cosine of the passed parameter (in radians)
- `tan()` - returns the tangent of the passed parameter (in radians)
- `asin()` - returns (in radians) the arcsine of the passed parameter
- `acos()` - returns (in radians) the arccosine of the passed parameter
- `atan()` - returns (in radians) the arctangent of the passed parameter
- `dtor()` - converts the passed parameter from degrees to radians
- `rtod()` - converts the passed parameter from radians to degrees
- `sinh()` - returns the hyperbolic sine of the passed parameter
- `cosh()` - returns the hyperbolic cosine of the passed parameter
- `tanh()` - returns the hyperbolic tangent of the passed parameter
- `asinh()` - returns the hyperbolic arcsine of the passed parameter
- `acosh()` - returns the hyperbolic arccosine of the passed parameter
- `atanh()` - returns the hyperbolic arctangent of the passed parameter

Functions that take no parameters:

- `pi()` - returns the value of π
- `pi_2()` - returns the value of π/2
- `pi_4()` - returns the value of π/2
- `sqrt2()` - returns the value of the square root of 2
- `e()` - returns the value of e
- `log2e()` - returns the value of the log base 2 of e
- `log10e()` - returns the value of the log base 10 of e
- `ln2()` - returns the value of the log base e of 2
- `ln10()` - returns the value of the log base e of 10

## Usage

Simply copy the "DDMathParser" subfolder into your project, `#import "DDMathParsing.h"`, and you're good to go.

There are several ways to evaluate strings, depending on how much customization you want to do:

### NSString

    NSLog(@"%@", [@"1 + 2" numberByEvaluatingString]);
    
Useful for the simplest evaluations (ie, no variables).  Uses the `[DDMathEvaluator sharedMathEvaluator]` and all functions registered with it.
    
### DDExpression

	DDExpression * e = [DDExpression expressionFromString:@"1 + 2"];
	NSLog(@"%@", [e evaluateWithSubstitutions:nil evaluator:nil]);
	
Useful for specifying variable substitutions or a custom evaluator.

### DDMathEvaluator

    DDMathEvaluator * eval = [DDMathEvaluator sharedMathEvaluator];
    NSLog(@"%@", [eval evaluateString:@"1 + 2" withSubstitutions:nil]);
    
Useful for specifying variable substitutions or a custom evaluator.

### DDMathParser

    DDMathParser * parser = [DDMathParser mathParserWithString:@"1 + 2"];
    DDExpression * e = [parser parsedExpression];
    NSLog(@"%@", [e evaluateWithSubstitutions:nil evaluator:nil]);
    
Useful for specifying a custom parser or custom operator associativities, specifying variables, or specifying a custom evaluator.

## Compatibility

`DDMathParser` requires blocks, so therefore is only compatible with iOS 4+ and Mac OS X 10.6+.

## License

Copyright (c) 2010 Dave DeLong

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.