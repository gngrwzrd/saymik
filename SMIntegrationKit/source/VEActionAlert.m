
#import "VEActionAlert.h"

@implementation VEActionAlert

- (void) execute {
	NSURL * url = [_request URL];
	NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSArray * values = [query componentsSeparatedByString:@"|"];
	UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[values objectAtIndex:0]
		message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
	for(int i = 1; i < [values count]; i++) {
		[alertView addButtonWithTitle:[values objectAtIndex:i]];
	}
	[alertView show];
	[alertView release];
	[self finish];
}

- (BOOL) requiresPersistence {
	return FALSE;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: VEActionAlert");
	#endif
	[super dealloc];
}

@end
