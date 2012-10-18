
#import "SMAdActionMethodCall.h"

@implementation SMAdActionMethodCall

- (void) execute {
	NSString * sel = [_message objectForKey:@"selector"];
	NSArray * args = [_message objectForKey:@"args"];
	SEL objcsel = NSSelectorFromString(sel);
	[_selcontext performSelector:objcsel withObject:args];
	[self finish];
}

- (BOOL) requiresPersistence {
	return TRUE;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionMethodCall");
	#endif
	[super dealloc];
}

@end
