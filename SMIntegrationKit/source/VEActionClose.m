
#import "VEActionClose.h"

@implementation VEActionClose

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
	NSLog(@"DEALLOC: VEActionClose");
	#endif
	[super dealloc];
}

@end
