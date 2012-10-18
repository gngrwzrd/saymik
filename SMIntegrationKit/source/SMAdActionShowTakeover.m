
#import "SMAdActionShowTakeover.h"

@implementation SMAdActionShowTakeover

- (void) execute {
	if(_delegate && [_delegate respondsToSelector:@selector(actionWantsToShowTakeover:)]) {
		[_delegate actionWantsToShowTakeover:self];
	}
	[self finish];
}

- (BOOL) requiresPersistence {
	return FALSE;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionShowTakeover");
	#endif
	[super dealloc];
}

@end
