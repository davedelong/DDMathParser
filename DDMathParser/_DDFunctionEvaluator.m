//
//  __DDFunctionUtilities.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/21/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathParser.h"
#import "_DDFunctionEvaluator.h"
#import "DDExpression.h"
#import "DDMathParserMacros.h"
#import "DDMathEvaluator+Private.h"
#import "_DDOperatorInfo.h"
#import <objc/runtime.h>



inline DDExpression* _DDDTOR(DDExpression *e, DDMathEvaluator *evaluator, NSError **error) {
    DDExpression *final = e;
    if ([evaluator angleMeasurementMode] == DDAngleMeasurementModeDegrees) {
        if ([e expressionType] != DDExpressionTypeFunction || ![[e function] isEqualToString:@"dtor"]) {
            final = [DDExpression functionExpressionWithFunction:@"dtor"
                                                       arguments:[NSArray arrayWithObject:e]
                                                           error:error];
        }
    }
    return final;
}

inline DDExpression* _DDRTOD(DDExpression *e, DDMathEvaluator *evaluator, NSError **error) {
    DDExpression *final = e;
    if ([evaluator angleMeasurementMode] == DDAngleMeasurementModeDegrees) {
        if ([e expressionType] != DDExpressionTypeFunction || ![[e function] isEqualToString:@"rtod"]) {
            final = [DDExpression functionExpressionWithFunction:@"rtod"
                                                       arguments:[NSArray arrayWithObject:e]
                                                           error:error];
        }
    }
    return final;
}

typedef DDExpression* (*_DDFunctionEvaluatorIMP)(id, SEL, NSArray *, NSDictionary *, NSError **);

static NSString *const _DDFunctionSelectorSuffix = @":variables:error:";

@implementation _DDFunctionEvaluator {
    __unsafe_unretained DDMathEvaluator *_evaluator;
}

@synthesize evaluator=_evaluator;

+ (NSOrderedSet *)standardFunctions {
    static NSOrderedSet *functions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] init];
        
        unsigned int methodCount = 0;
        Method *methods = class_copyMethodList([_DDFunctionEvaluator class], &methodCount);
        if (methods) {
            for (unsigned int i = 0; i < methodCount; ++i) {
                Method m = methods[i];
                NSString *selector = NSStringFromSelector(method_getName(m));
                NSString *suffix = _DDFunctionSelectorSuffix;
                if ([selector hasSuffix:suffix]) {
                    NSInteger index = [selector length] - [suffix length];
                    NSString *functionName = [selector substringToIndex:index];
                    if ([functionName isEqualToString:@"evaluateFunction"] == NO) {
                        [set addObject:functionName];
                    }
                }
            }
            
            free(methods);
        }
        
        [set sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        functions = [set copy];
        DD_RELEASE(set);
    });
    return functions;
}

+ (BOOL)isStandardFunction:(NSString *)functionName {
    return [[self standardFunctions] containsObject:[functionName lowercaseString]];
}

- (id)initWithMathEvaluator:(DDMathEvaluator *)evaluator {
    self = [super init];
    if (self) {
        _evaluator = evaluator;
    }
    return self;
}

- (DDExpression *)evaluateFunction:(_DDFunctionExpression *)expression variables:(NSDictionary *)variables error:(NSError **)error {
    NSString *functionName = [[expression function] lowercaseString];
    NSString *selector = [NSString stringWithFormat:@"%@%@", functionName, _DDFunctionSelectorSuffix];
    SEL sel = NSSelectorFromString(selector);
    
    DDExpression *evaluation = nil;
    if ([[self class] instancesRespondToSelector:sel]) {
        _DDFunctionEvaluatorIMP imp = (_DDFunctionEvaluatorIMP)[[self class] instanceMethodForSelector:sel];
        evaluation = imp(self, sel, [expression arguments], variables, error);
    } else {
        evaluation = [[self evaluator] resolveFunction:expression variables:variables error:error];
    }
    return evaluation;
}

- (DDExpression *)add:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *firstValue = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(firstValue);
	
	NSNumber *secondValue = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
	RETURN_IF_NIL(secondValue);
    NSNumber *result = [NSNumber numberWithDouble:[firstValue doubleValue] + [secondValue doubleValue]];
    return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)subtract:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *firstValue = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(firstValue);
	NSNumber *secondValue = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
	RETURN_IF_NIL(secondValue);
    NSNumber *result = [NSNumber numberWithDouble:[firstValue doubleValue] - [secondValue doubleValue]];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)multiply:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *firstValue = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(firstValue);
	NSNumber *secondValue = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
	RETURN_IF_NIL(secondValue);
    NSNumber *result = [NSNumber numberWithDouble:[firstValue doubleValue] * [secondValue doubleValue]];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)divide:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *firstValue = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(firstValue);
	NSNumber *secondValue = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
	RETURN_IF_NIL(secondValue);
    NSNumber *result = [NSNumber numberWithDouble:[firstValue doubleValue] / [secondValue doubleValue]];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)mod:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *firstValue = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(firstValue);
	NSNumber *secondValue = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
	RETURN_IF_NIL(secondValue);
    NSNumber *result = [NSNumber numberWithDouble:fmod([firstValue doubleValue], [secondValue doubleValue])];
    return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)negate:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
	NSNumber *firstValue = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(firstValue);
    NSNumber *result = [NSNumber numberWithDouble:-1 * [firstValue doubleValue]];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)factorial:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
	NSNumber *firstValue = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(firstValue);
    
    NSNumber *result = [NSNumber numberWithDouble:tgamma([firstValue doubleValue]+1)];
    return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)pow:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *base = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(base);
	NSNumber *exponent = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
	RETURN_IF_NIL(exponent);
    
    NSNumber *result = [NSNumber numberWithDouble:pow([base doubleValue], [exponent doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)nthroot:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *base = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(base);
	NSNumber *root = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
	RETURN_IF_NIL(root);
    
    NSNumber *result = [NSNumber numberWithDouble:pow([base doubleValue], 1/[root doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)and:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *first = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(first);
	NSNumber *second = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
	RETURN_IF_NIL(second);
    NSNumber *result = [NSNumber numberWithInteger:([first integerValue] & [second integerValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)or:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *first = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(first);
	NSNumber *second = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
	RETURN_IF_NIL(second);
    NSNumber *result = [NSNumber numberWithInteger:([first integerValue] | [second integerValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)not:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
	NSNumber *first = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(first);
    NSNumber *result = [NSNumber numberWithInteger:(~[first integerValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)xor:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *first = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(first);
	NSNumber *second = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
	RETURN_IF_NIL(second);
    NSNumber *result = [NSNumber numberWithInteger:([first integerValue] ^ [second integerValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)rshift:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *first = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(first);
	NSNumber *second = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
	RETURN_IF_NIL(second);
    NSNumber *result = [NSNumber numberWithInteger:[first integerValue] >> [second integerValue]];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)lshift:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *first = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(first);
	NSNumber *second = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
	RETURN_IF_NIL(second);
    NSNumber *result = [NSNumber numberWithInteger:[first integerValue] << [second integerValue]];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)average:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_GTOE_N_ARGS(2);
    DDExpression *sumExpression = [self sum:arguments variables:variables error:error];
	RETURN_IF_NIL(sumExpression);
    
    double sum = [[sumExpression number] doubleValue];
    NSNumber *avg = [NSNumber numberWithDouble:sum / [arguments count]];
	return [DDExpression numberExpressionWithNumber:avg];
}

- (DDExpression *)sum:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_GTOE_N_ARGS(1);
	NSMutableArray * evaluatedNumbers = [NSMutableArray array];
	for (DDExpression * e in arguments) {
        NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
        RETURN_IF_NIL(n);
		[evaluatedNumbers addObject:n];
	}
    
    double sum = 0;
    for (NSNumber *value in evaluatedNumbers) {
        sum += [value doubleValue];
    }
    NSNumber *result = [NSNumber numberWithDouble:sum];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)count:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
#pragma unused(variables)
	REQUIRE_GTOE_N_ARGS(1);
	return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithMantissa:[arguments count] exponent:0 isNegative:NO]];
}

- (DDExpression *)min:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_GTOE_N_ARGS(2);
    NSNumber *result = nil;
	for (NSUInteger index = 0; index < [arguments count]; ++index) {
		DDExpression *e = [arguments objectAtIndex:index];
		NSNumber *value = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
		RETURN_IF_NIL(value);
        if (index == 0 || [result compare:value] == NSOrderedDescending) {
            //result > value (or is first index)
            //value is smaller
            result = value;
		}
	}
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)max:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_GTOE_N_ARGS(2);
    NSNumber *result = nil;
	for (NSUInteger index = 0; index < [arguments count]; ++index) {
		DDExpression *e = [arguments objectAtIndex:index];
		NSNumber *value = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
		RETURN_IF_NIL(value);
        if (index == 0 || [result compare:value] == NSOrderedAscending) {
            //result < value (or is first index)
            //value is larger
            result = value;
		}
	}
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)median:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_GTOE_N_ARGS(2);
	NSMutableArray *evaluatedNumbers = [NSMutableArray array];
	for (DDExpression *e in arguments) {
        NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
        RETURN_IF_NIL(n);
		[evaluatedNumbers addObject:n];
	}
	[evaluatedNumbers sortUsingSelector:@selector(compare:)];
	
	NSNumber *median = nil;
	if (([evaluatedNumbers count] % 2) == 1) {
		NSUInteger index = floor([evaluatedNumbers count] / 2);
		median = [evaluatedNumbers objectAtIndex:index];
	} else {
		NSUInteger lowIndex = floor([evaluatedNumbers count] / 2);
		NSUInteger highIndex = ceil([evaluatedNumbers count] / 2);
        NSNumber *low = [evaluatedNumbers objectAtIndex:lowIndex];
        NSNumber *high = [evaluatedNumbers objectAtIndex:highIndex];
        median = [NSNumber numberWithDouble:([low doubleValue] + [high doubleValue])/2];
	}
	return [DDExpression numberExpressionWithNumber:median];
}

- (DDExpression *)stddev:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_GTOE_N_ARGS(2);
	DDExpression * avgExpression = [self average:arguments variables:variables error:error];
	RETURN_IF_NIL(avgExpression);
    
    double avg = [[avgExpression number] doubleValue];
    double stddev = 0;
    for (DDExpression *e in arguments) {
        NSNumber *argValue = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
        RETURN_IF_NIL(argValue);
        double diff = avg - [argValue doubleValue];
        diff = diff * diff;
        stddev += diff;
    }
    stddev /= [arguments count];
    stddev = sqrt(stddev);
    NSNumber *result = [NSNumber numberWithDouble:stddev];
	
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)sqrt:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
	NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:sqrt([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)random:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	if ([arguments count] > 2) {
		if (error != nil) {
            
            *error = ERR(DDErrorCodeInvalidNumberOfArguments, @"random() may only have up to 2 arguments");
		}
		return nil;
	}
	
	NSMutableArray * params = [NSMutableArray array];
	for (DDExpression *e in arguments) {
		NSNumber *value = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
		RETURN_IF_NIL(value);
		[params addObject:value];
	}
	
	NSInteger random = arc4random();
	
	if ([params count] == 1) {
		NSNumber *lowerBound = [params objectAtIndex:0];
		while (random < [lowerBound integerValue]) {
            random += [lowerBound integerValue];
		}
	} else if ([params count] == 2) {
		NSNumber *lowerBound = [params objectAtIndex:0];
		NSNumber *upperBound = [params objectAtIndex:1];
		
		if ([upperBound integerValue] <= [lowerBound integerValue]) {
            if (error != nil) {
                *error = ERR(DDErrorCodeInvalidArgument, @"upper bound (%ld) of random() must be larger than lower bound (%ld)", [upperBound integerValue], [lowerBound integerValue]);
            }
            return nil;
		}
		
		long long range = llabs(([upperBound longLongValue] - [lowerBound longLongValue]) + 1);
		random = random % range;
		random += [lowerBound longLongValue];
	}
	
	return [DDExpression numberExpressionWithNumber:[NSNumber numberWithLongLong:random]];
}

- (DDExpression *)log:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
	NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:log10([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)ln:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
	NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(n);
	return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:log([n doubleValue])]];
}

- (DDExpression *)log2:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
	NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:log2([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)exp:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
	NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:exp([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)ceil:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    NSNumber *result = [NSNumber numberWithDouble:ceil([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)abs:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithLongLong:llabs([n longLongValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)floor:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:floor([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)percent:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
    REQUIRE_N_ARGS(1);
    
    DDExpression *percentArgument = [arguments objectAtIndex:0];
    DDExpression *percentExpression = [percentArgument parentExpression];
    DDExpression *percentContext = [percentExpression parentExpression];
    
    NSString *parentFunction = [percentContext function];
    _DDOperatorInfo *operatorInfo = [[_DDOperatorInfo infosForOperatorFunction:parentFunction] lastObject];
    
    NSNumber *context = [NSNumber numberWithInt:1];
    
    if ([operatorInfo arity] == DDOperatorArityBinary) {
        if ([parentFunction isEqualToString:DDOperatorAdd] || [parentFunction isEqualToString:DDOperatorMinus]) {
            
            BOOL percentIsRightArgument = ([[percentContext arguments] objectAtIndex:1] == percentExpression);
            
            if (percentIsRightArgument) {
                DDExpression *baseExpression = [[percentContext arguments] objectAtIndex:0];
                context = [[self evaluator] evaluateExpression:baseExpression withSubstitutions:variables error:error];
                
            }
        }
    }
    
    NSNumber *percent = [[self evaluator] evaluateExpression:percentArgument withSubstitutions:variables error:error];
    
    RETURN_IF_NIL(context);
    RETURN_IF_NIL(percent);
    
    NSNumber *result = [NSNumber numberWithDouble:[context doubleValue] * ([percent doubleValue] / 100.0)];
    return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)sin:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:sin([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)cos:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:cos([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)tan:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:tan([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)asin:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:asin([n doubleValue])];
	return _DDRTOD([DDExpression numberExpressionWithNumber:result], [self evaluator], error);
}

- (DDExpression *)acos:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:acos([n doubleValue])];
	return _DDRTOD([DDExpression numberExpressionWithNumber:result], [self evaluator], error);
}

- (DDExpression *)atan:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:atan([n doubleValue])];
	return _DDRTOD([DDExpression numberExpressionWithNumber:result], [self evaluator], error);
}

- (DDExpression *)sinh:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:sinh([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)cosh:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:cosh([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)tanh:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:tanh([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)asinh:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:asinh([n doubleValue])];
	return _DDRTOD([DDExpression numberExpressionWithNumber:result], [self evaluator], error);
}

- (DDExpression *)acosh:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:acosh([n doubleValue])];
	return _DDRTOD([DDExpression numberExpressionWithNumber:result], [self evaluator], error);
}

- (DDExpression *)atanh:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:atanh([n doubleValue])];
	return _DDRTOD([DDExpression numberExpressionWithNumber:result], [self evaluator], error);
}

- (DDExpression *)csc:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1/sin([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)sec:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1/cos([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)cotan:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1/tan([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)acsc:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1/asin([n doubleValue])];
	return _DDRTOD([DDExpression numberExpressionWithNumber:result], [self evaluator], error);
}

- (DDExpression *)asec:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1/acos([n doubleValue])];
	return _DDRTOD([DDExpression numberExpressionWithNumber:result], [self evaluator], error);
}

- (DDExpression *)acotan:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1/atan([n doubleValue])];
	return _DDRTOD([DDExpression numberExpressionWithNumber:result], [self evaluator], error);
}

- (DDExpression *)csch:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1/sinh([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)sech:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1/cosh([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)cotanh:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1/tanh([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)acsch:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1/sinh([n doubleValue])];
	return _DDRTOD([DDExpression numberExpressionWithNumber:result], [self evaluator], error);
}

- (DDExpression *)asech:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1/cosh([n doubleValue])];
	return _DDRTOD([DDExpression numberExpressionWithNumber:result], [self evaluator], error);
}

- (DDExpression *)acotanh:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1/atanh([n doubleValue])];
	return _DDRTOD([DDExpression numberExpressionWithNumber:result], [self evaluator], error);
}
// more trig functions
- (DDExpression *)versin:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1-cos([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)vercosin:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1+cos([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)coversin:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1-sin([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)covercosin:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:1+sin([n doubleValue])];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)haversin:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:(1-cos([n doubleValue]))/2];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)havercosin:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:(1+cos([n doubleValue]))/2];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)hacoversin:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:(1-sin([n doubleValue]))/2];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)hacovercosin:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:(1+sin([n doubleValue]))/2];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)exsec:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:(1/cos([n doubleValue]))-1];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)excsc:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:(1/sin([n doubleValue]))-1];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)crd:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    DDExpression *e = [arguments objectAtIndex:0];
    e = _DDDTOR(e, [self evaluator], error);
    NSNumber *n = [[self evaluator] evaluateExpression:e withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:2*sin([n doubleValue]/2)];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)dtor:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:[n doubleValue]/180 * M_PI];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)rtod:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
    NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    RETURN_IF_NIL(n);
    
    NSNumber *result = [NSNumber numberWithDouble:[n doubleValue]/M_PI * 180];
	return [DDExpression numberExpressionWithNumber:result];
}
#pragma mark Constant Functions
- (DDExpression *)phi:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
#pragma unused(variables)
	REQUIRE_N_ARGS(0);
	return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:1.6180339887498948]];
}

- (DDExpression *)pi:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
#pragma unused(variables)
	REQUIRE_N_ARGS(0);
    return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_PI]];
}

- (DDExpression *)pi_2:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
#pragma unused(variables)
	REQUIRE_N_ARGS(0);
	return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_PI_2]];
}

- (DDExpression *)pi_4:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
#pragma unused(variables)
	REQUIRE_N_ARGS(0);
	return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_PI_4]];
}

- (DDExpression *)tau:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
#pragma unused(variables)
	REQUIRE_N_ARGS(0);
	return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:2*M_PI]];
}

- (DDExpression *)sqrt2:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
#pragma unused(variables)
	REQUIRE_N_ARGS(0);
	return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_SQRT2]];
}

- (DDExpression *)e:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
#pragma unused(variables)
	REQUIRE_N_ARGS(0);
    return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_E]];
}

- (DDExpression *)log2e:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
#pragma unused(variables)
	REQUIRE_N_ARGS(0);
	return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_LOG2E]];
}

- (DDExpression *)log10e:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
#pragma unused(variables)
	REQUIRE_N_ARGS(0);
	return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_LOG10E]];
}

- (DDExpression *)ln2:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
#pragma unused(variables)
	REQUIRE_N_ARGS(0);
	return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_LN2]];
}

- (DDExpression *)ln10:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
#pragma unused(variables)
	REQUIRE_N_ARGS(0);
	return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_LN10]];
}
// logical functions
- (DDExpression *)l_and:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *left = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	NSNumber *right = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
    NSNumber *result = [NSNumber numberWithBool:[left boolValue] && [right boolValue]];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)l_or:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *left = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	NSNumber *right = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
    NSNumber *result = [NSNumber numberWithBool:[left boolValue] ||
                        
                        [right boolValue]];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)l_not:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(1);
	NSNumber *n = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
    NSNumber *result = [NSNumber numberWithBool:![n boolValue]];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)l_eq:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *left = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	NSNumber *right = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
    NSComparisonResult compare = [left compare:right];
    NSNumber *result = [NSNumber numberWithBool:compare == NSOrderedSame];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)l_neq:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *left = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	NSNumber *right = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
    NSComparisonResult compare = [left compare:right];
    NSNumber *result = [NSNumber numberWithBool:compare != NSOrderedSame];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)l_lt:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *left = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	NSNumber *right = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
    NSComparisonResult compare = [left compare:right];
    NSNumber *result = [NSNumber numberWithBool:compare == NSOrderedAscending];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)l_gt:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *left = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	NSNumber *right = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
    NSComparisonResult compare = [left compare:right];
    NSNumber *result = [NSNumber numberWithBool:compare == NSOrderedDescending];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)l_ltoe:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *left = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	NSNumber *right = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
    NSComparisonResult compare = [left compare:right];
    NSNumber *result = [NSNumber numberWithBool:compare == NSOrderedSame || compare == NSOrderedAscending];
	return [DDExpression numberExpressionWithNumber:result];
}

- (DDExpression *)l_gtoe:(NSArray *)arguments variables:(NSDictionary *)variables error:(NSError **)error {
	REQUIRE_N_ARGS(2);
	NSNumber *left = [[self evaluator] evaluateExpression:[arguments objectAtIndex:0] withSubstitutions:variables error:error];
	NSNumber *right = [[self evaluator] evaluateExpression:[arguments objectAtIndex:1] withSubstitutions:variables error:error];
    NSComparisonResult compare = [left compare:right];
    NSNumber *result = [NSNumber numberWithBool:compare == NSOrderedSame || compare == NSOrderedDescending];
	return [DDExpression numberExpressionWithNumber:result];
}

@end
