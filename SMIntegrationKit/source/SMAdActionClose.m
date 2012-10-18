
#import "SMAdActionClose.h"

@implementation SMAdActionClose

- (void) execute {
	if(_delegate && [_delegate respondsToSelector:@selector(actionWantsToCloseTakeover:)]) {
		[_delegate actionWantsToCloseTakeover:self];
	}
	[self finish];
}

- (BOOL) requiresPersistence {
	return FALSE;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionClose");
	#endif
	[super dealloc];
}

@end
