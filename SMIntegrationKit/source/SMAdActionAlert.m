
#import "SMAdActionAlert.h"

@implementation SMAdActionAlert

- (void) execute {
	NSString * msg = [_message objectForKey:@"message"];
	if(!msg) msg = [_message objectForKey:@"msg"];
	if(!msg) {
		[self finish];
		return;
	}
	UIAlertView * alert = [[UIAlertView alloc] init];
	[alert setMessage:msg];
	[alert addButtonWithTitle:@"OK"];
	[alert autorelease];
	[alert show];
}

- (void) alertViewCancel:(UIAlertView *) alertView {
	[self finish];
}

- (void)
alertView:(UIAlertView *) alertView
didDismissWithButtonIndex:(NSInteger) buttonIndex
{
	[self finish];
}

- (BOOL) requiresPersistence {
	return true;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionAlert");
	#endif
	[super dealloc];
}

@end
