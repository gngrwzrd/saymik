
#import "SMAdActionPhone.h"

@implementation SMAdActionPhone

- (void) execute {
	
}

- (BOOL) returnForUIWebView {
	return FALSE;
}

- (BOOL) requiresPersistence {
	return FALSE;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionPhone");
	#endif
	[super dealloc];
}

@end
