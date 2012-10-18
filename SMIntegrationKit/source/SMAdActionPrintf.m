
#import "SMAdActionPrintf.h"

@implementation SMAdActionPrintf

- (void) execute {
	NSLog(@"%@",[_message objectForKey:@"printf"]);
	[self finish];
}

- (BOOL) requiresPersistence {
	return NO;
}

- (BOOL) returnForUIWebView {
	return NO;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionPrintf");
	#endif
	[super dealloc];
}

@end
