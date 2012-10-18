
#import "VEActionURL.h"

@implementation VEActionURL

- (void) execute {
	NSURL * url = [_request URL];
	NSString * custom = [NSString stringWithFormat:@"%@:%@",url.host,url.path];
	if(_delegate && [_delegate respondsToSelector:@selector(actionWantsToCloseTakeover:)]) {
		[_delegate actionWantsToCloseTakeover:self];
	}
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:custom]];
	[self finish];
}

- (BOOL) requiresPersistence {
	return FALSE;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: VEActionURL");
	#endif
	[super dealloc];
}

@end
