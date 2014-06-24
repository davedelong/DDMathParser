//
//  NSString+DDMathParsing.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/21/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "NSString+DDMathParsing.h"
#import "DDExpression.h"
#import "DDMathEvaluator.h"

NSString *const DDMathParsingKeyPathRegexPattern = @"\\$([a-zA-Z\\.@\\[\\]]*)?";

@implementation NSString (DDMathParsing)

- (NSNumber *)numberByEvaluatingString {
	return [self numberByEvaluatingStringWithSubstitutions:nil];
}

- (NSNumber *)numberByEvaluatingStringWithSubstitutions:(NSDictionary *)substitutions {
	NSError *error = nil;
	NSNumber *returnValue = [self numberByEvaluatingStringWithSubstitutions:substitutions error:&error];
	if (returnValue == nil) {
		NSLog(@"error: %@", error);
	}
	return returnValue;
}

- (NSNumber *)numberByEvaluatingStringWithSubstitutions:(NSDictionary *)substitutions error:(NSError **)error {
    return [[DDMathEvaluator defaultMathEvaluator] evaluateString:self withSubstitutions:substitutions error:error];
}

- (NSNumber *)numberByEvaluatingStringAgainstObject:(id)object
{
    NSError *error = nil;
    NSNumber *returnValue = [self numberByEvaluatingStringAgainstObject: object
                                                                  error: &error];
    if (returnValue == nil)
    {
        NSLog(@"error: %@", error);
    }
    
    return returnValue;
}

- (NSNumber *)numberByEvaluatingStringAgainstObject:(id)object error:(NSError **)error
{
    NSRegularExpression *keyPathRegex = [NSRegularExpression regularExpressionWithPattern: DDMathParsingKeyPathRegexPattern
                                                                                  options: 0
                                                                                    error: error];
    if (error && *error)
        return nil;
    
    NSMutableString *parsedString = [self mutableCopy];
    NSArray *keyPathMatches = [keyPathRegex matchesInString: self options: 0 range: NSMakeRange(0, [self length])];
    for (NSTextCheckingResult *keyPathMatch in keyPathMatches)
    {
        NSRange keyPathRange = NSMakeRange(keyPathMatch.range.location + 1, keyPathMatch.range.length - 1); // Inset by 1 to account for leading '$'
        NSString *keyPath = [self substringWithRange: keyPathRange];
        
        [parsedString replaceCharactersInRange: [keyPathMatch range]
                                    withString: [NSString stringWithFormat: @"%@", [object valueForKeyPath: keyPath]]];
    }
    
    return [parsedString numberByEvaluatingStringWithSubstitutions: nil
                                                             error: error];
}

@end
