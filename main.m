#import <Foundation/Foundation.h>
#import "DDMathParser.h"
#import "DDMathStringTokenizer.h"

NSString* readLine(void);
void listFunctions(void);

NSString* readLine() {
    
    NSMutableData *data = [NSMutableData data];
    
    do {
        char c = getchar();
        if (c == '\r' || c == '\n') { break; }
        [data appendBytes:&c length:1];
        
    } while (1);
    
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
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
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
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
        
        NSNumber *value = [expression evaluateWithSubstitutions:nil evaluator:nil error:&error];
        [tokenizer release];
        
        if (value == nil) {
            printf("\tERROR: %s\n", [[error description] UTF8String]);
        } else {
            printf("\t%s = %s\n", [[expression description] UTF8String], [[value description] UTF8String]);
        }
        printf("\tSimplified = %s\n", [[[expression simplifiedExpression] description] UTF8String]);

	} while (1);

    // insert code here...
		printf("Goodbye!\n");
    [pool drain];
    return 0;
}
