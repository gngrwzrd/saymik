
#import "SMAdActionLaunchURL.h"

@implementation SMAdActionLaunchURL

- (void) execute {
	if([_message objectForKey:@"shouldCloseExperience"]) {
		if(_delegate && [_delegate \
			respondsToSelector:@selector(actionWantsToCloseTakeover:)])
		{
			[_delegate actionWantsToCloseTakeover:self];
		}
	}
	NSURL * url = NULL;
	NSString * surl = [_message objectForKey:@"url"];
	if(!surl) surl = [_message objectForKey:@"href"];
	if(!surl) surl = [_message objectForKey:@"location"];
	if(!surl) url = [_request URL];
	else url = [NSURL URLWithString:surl];
	[[UIApplication sharedApplication] openURL:url];
	[self finish];
}

- (BOOL) returnForUIWebView {
	return FALSE;
}

- (BOOL) requiresPersistence {
	return FALSE;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionLaunchURL");
	#endif
	[super dealloc];
}

@end
