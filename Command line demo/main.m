#import <Foundation/Foundation.h>
#import "DDMathParser.h"
#import "DDMathStringTokenizer.h"

NSString* readLine(void);
void listFunctions(void);

NSString* readLine() {
    NSCharacterSet *valid = [DDMathStringTokenizer legalCharacters];
    NSMutableData *data = [NSMutableData data];
    
    
    do {
        char c = getchar();
        if (c > 0xffff) { continue; }
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:(unichar)c]) { break; }
        if (![valid characterIsMember:(unichar)c]) { continue; }
        
        [data appendBytes:&c length:sizeof(char)];
    } while (1);
    
    return DD_AUTORELEASE([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

void listFunctions() {
	printf("\nFunctions available:\n");
	NSArray * functions = [[DDMathEvaluator sharedMathEvaluator] registeredFunctions];
	for (NSString * function in functions) {
		printf("\t%s()\n", [function UTF8String]);
	}
}

int main (int argc, const char * argv[]) {
#pragma unused(argc, argv)
    
#if DD_HAS_ARC
    @autoreleasepool {
#else
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
#endif
	
	printf("Math Evaluator!\n");
	printf("\ttype a mathematical expression to evaluate it.\n");
	printf("\nStandard operators available: + - * / %% ! & | ~ ^ << >>\n");
	printf("\nType \"list\" to show available functions\n");
	printf("Type \"exit\" to quit\n");
    
    [DDParser setDefaultPowerAssociativity:DDOperatorAssociativityRight];
	
	NSString * line = nil;
	do {
		printf("> ");
		line = readLine();
		if ([line isEqual:@"exit"]) { break; }
		if ([line isEqual:@"list"]) { listFunctions(); continue; }
		
        NSError *error = nil;
        DDMathStringTokenizer *tokenizer = [[DDMathStringTokenizer alloc] initWithString:line error:&error];
        DDParser *parser = [DDParser parserWithTokenizer:tokenizer error:&error];
        
        DDExpression *expression = [parser parsedExpressionWithError:&error];
        DDExpression *rewritten = [[DDMathEvaluator sharedMathEvaluator] expressionByRewritingExpression:expression];
        
        NSNumber *value = [rewritten evaluateWithSubstitutions:nil evaluator:nil error:&error];
        DD_RELEASE(tokenizer);
        
        if (value == nil) {
            printf("\tERROR: %s\n", [[error description] UTF8String]);
        } else {
            if (rewritten != expression) {
                printf("\t%s REWRITTEN AS %s\n", [[expression description] UTF8String], [[rewritten description] UTF8String]);
            }
            printf("\t%s = %s\n", [[rewritten description] UTF8String], [[value description] UTF8String]);
        }
        

	} while (1);

    // insert code here...
		printf("Goodbye!\n");
        
#if DD_HAS_ARC
    }
#else
    [pool drain];
#endif
    return 0;
}
