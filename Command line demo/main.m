#import <Foundation/Foundation.h>
#import "DDMathParser.h"
#import "DDMathStringTokenizer.h"
#import "DDMathOperator.h"

NSString* readLine(void);
void listFunctions(void);
void listOperators(void);

NSString* readLine() {
    NSMutableData *data = [NSMutableData data];
    
    
    do {
        char c = getchar();
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:(unichar)c]) { break; }
        
        [data appendBytes:&c length:sizeof(char)];
    } while (1);
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

void listFunctions() {
	printf("\nFunctions available:\n");
	NSArray * functions = [[DDMathEvaluator defaultMathEvaluator] registeredFunctions];
	for (NSString * function in functions) {
		printf("\t%s()\n", [function UTF8String]);
	}
}

void listOperators() {
	printf("\nOperators available:\n");
    NSArray *knownOperators = [DDMathOperator allOperators];
    for (DDMathOperator *op in knownOperators) {
        printf("\t%s (%s, %s associative) invokes %s()\n",
               [[op.tokens componentsJoinedByString:@", "] UTF8String],
               op.arity == DDOperatorArityBinary ? "binary" : (op.arity == DDOperatorArityUnary ? "unary" : "unknown"),
               op.associativity == DDOperatorAssociativityLeft ? "left" : "right",
               [op.function UTF8String]);
	}
}

int main (int argc, const char * argv[]) {
#pragma unused(argc, argv)
    
    @autoreleasepool {
        
        printf("Math Evaluator!\n");
        printf("\tType a mathematical expression to evaluate it.\n");
        printf("\tType \"list\" to show available functions\n");
        printf("\tType \"operators\" to show available operators\n");
        printf("\tType \"exit\" to quit\n");
        
        [DDParser setDefaultPowerAssociativity:DDOperatorAssociativityRight];
        DDMathEvaluator *evaluator = [[DDMathEvaluator alloc] init];
        [evaluator setFunctionResolver:^DDMathFunction (NSString *name) {
            return [^DDExpression* (NSArray *args, NSDictionary *substitutions, DDMathEvaluator *eval, NSError **error) {
                return [DDExpression numberExpressionWithNumber:@42];
            } copy];
        }];
        
        NSString * line = nil;
        do {
            printf("> ");
            line = readLine();
            if ([line isEqual:@"exit"]) { break; }
            if ([line isEqual:@"list"]) { listFunctions(); continue; }
            if ([line isEqual:@"operators"]) { listOperators(); continue; }
            
            NSError *error = nil;
            
            DDMathStringTokenizer *tokenizer = [[DDMathStringTokenizer alloc] initWithString:line error:&error];
            DDParser *parser = [DDParser parserWithTokenizer:tokenizer error:&error];
            
            DDExpression *expression = [parser parsedExpressionWithError:&error];
            DDExpression *rewritten = [evaluator expressionByRewritingExpression:expression];
            
            NSNumber *value = [evaluator evaluateExpression:rewritten withSubstitutions:nil error:&error];
            
            if (value == nil) {
                printf("\tERROR: %s\n", [[error description] UTF8String]);
            } else {
                if (rewritten != expression) {
                    printf("\t%s REWRITTEN AS %s\n", [[expression description] UTF8String], [[rewritten description] UTF8String]);
                }
                printf("\t%s = %s\n", [[rewritten description] UTF8String], [[value description] UTF8String]);
            }
            
            
        } while (1);
        
		printf("Goodbye!\n");
        
    }
    return 0;
}
