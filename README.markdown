# DDMathParser

You have an `NSString`.  You want an `NSNumber`.  Previously, you would have to rely on [abusing `NSPredicate`](http://tumblr.com/xqopow93r) to turn your string into an `NSExpression` that you could then evaluate.  However, this has a major flaw:  extending it to support functions that aren't built-in to `NSExpression` provided for some awkward syntax.  So if you really need `sin()`, you have to jump through some intricate hoops to get it.

You could also have used [`GCMathParser`](http://apptree.net/parser.htm).  This, however, isn't extensible at all.  So if you really needed a `floor()` function, you're out of luck.

Thus, `DDMathParser`.  It is written to be identical to `NSExpression` in all the ways that matter (in fact, it actually uses `NSExpression` to evaluate many of its built-in functions), but with the major addition that you can define new functions as you need.

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
    
### Variables

If you don't know what the value of a particular term should be when the string is constructed, that's ok; simply use a variable:

    NSString * math = @"6 * $a";
    
Then when you figure out what the value is supposed to be, you can pass it along in the substitution dictionary:

    NSLog(@"%@", [[DDMathEvaluator sharedMathEvaluator] evaluateString:math withSubstitutions:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:7] forKey:@"a"]]); //logs "42"
    
Variables are denoted in the source string as beginning with `$` and can contain numbers or letters.  They are case sensitive.  (`$a` is not the same as `$A`)
    
### Associativity

By default, all binary operators are left associative.  That means if you give a string, such as `@"2 ** 3 ** 2"`, it will be parsed as `@"(2 ** 3) ** 2`, in order to maintain parity with `NSExpression`.

If you want this operator to be parsed with right associativity, you can do so like this:

    DDMathParser * parser = [DDMathParser mathParserWithString:@"2 ** 3 ** 2"];
    [parser setPowerAssociativity:DDMathParserAssociativityRight];
    DDExpression * e = [parser parsedExpression];
   
All binary operators can have their associativity changed this way.

## Usage

Simply copy the "DDMathParser" subfolder into your project, `#import "DDMathParsing.h"`, and you're good to go.

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