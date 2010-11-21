#import <Foundation/Foundation.h>
#import "DDMathEvaluator.h"

NSString* readLine() {
	NSMutableString * str = [NSMutableString string];
	char nextChar = '\0';
	do {
		nextChar = getchar();
		if (nextChar != '\0' && [[NSCharacterSet newlineCharacterSet] characterIsMember:nextChar] == NO) {
			[str appendFormat:@"%C", nextChar];
		} else {
			break;
		}
	} while (1);
	return str;
}

void listFunctions() {
	printf("\nFunctions available:\n");
	NSArray * functions = [[DDMathEvaluator sharedMathEvaluator] registeredFunctions];
	for (NSString * function in functions) {
		printf("\t%s()\n", [function UTF8String]);
	}
}

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	printf("Math Evaluator!\n");
	printf("\ttype a mathematical expression to evaluate it.\n");
	printf("\nStandard operators available: + - * / %% ! & | ~ ^ << >>\n");
	printf("\nType \"list\" to show available functions\n");
	printf("Type \"exit\" to quit\n");
	
	NSString * line = nil;
	do {
		printf("> ");
		line = readLine();
		if ([line isEqual:@"exit"]) { break; }
		if ([line isEqual:@"list"]) { listFunctions(); continue; }
		
		NSNumber * value = [[DDMathEvaluator sharedMathEvaluator] evaluateString:line withSubstitutions:nil];
		printf("\t%s = %s\n", [line UTF8String], [[value description] UTF8String]);

	} while (1);

    // insert code here...
		printf("Goodbye!\n");
    [pool drain];
    return 0;
}
