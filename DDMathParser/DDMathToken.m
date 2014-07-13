//
//  DDMathToken.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/16/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathParser.h"
#import "DDMathToken.h"
#import "DDMathOperator.h"

@implementation DDMathToken

- (id)initWithToken:(NSString *)t type:(DDTokenType)type operator:(DDMathOperator *)op {
	self = [super init];
	if (self) {
        _token = [t copy];
		_tokenType = type;
		
		if (_tokenType == DDTokenTypeOperator) {
            _mathOperator = op;
            _ambiguous = (_mathOperator == nil);
		} else if (_tokenType == DDTokenTypeNumber) {
            _numberValue = [[NSDecimalNumber alloc] initWithString:[self token]];
            if (_numberValue == nil) {
                NSLog(@"supposedly invalid number: %@", [self token]);
                _numberValue = @0;
            }
        }
	}
	return self;
}

- (NSString *)description {
	NSMutableString * d = [NSMutableString string];
	if (_tokenType == DDTokenTypeVariable) {
		[d appendString:@"$"];
	}
	[d appendString:_token];
	return d;
}

- (NSString *)debugDescription {
    NSMutableString *d = [NSMutableString stringWithString:[self description]];
    if (_tokenType == DDTokenTypeOperator) {
        if (_ambiguous) {
            [d appendString:@" {AMBIGUOUS}"];
        } else {
            [d appendFormat:@" %@", [self.mathOperator debugDescription]];
        }
    }
    return d;
}

- (void)setMathOperator:(DDMathOperator *)op {
    _mathOperator = op;
    _ambiguous = (_mathOperator == nil);
}

@end
