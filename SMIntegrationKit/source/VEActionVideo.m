
#import "VEActionVideo.h"

@implementation VEActionVideo

- (void) showAlert {
	UIAlertView * alert = [[UIAlertView alloc] init];
	[alert setMessage:@"Video playback only available in iOS 3.2 or later."];
	[alert addButtonWithTitle:@"OK"];
	[alert show];
	[alert release];
}

- (void) execute {

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30200
	//compile time check. video only supported on >= 3.2 iOS.
	
	[self showAlert];
	[self finish];
	return;
#endif
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	//compile time check. video only supported on >= 3.2 iOS.
	
	//runtime check. if we're on an iOS older than 3.2, video not
	//supported, show alert.
	if([SMAdUtility iOSVersion] < 3.2) {
		[self showAlert];
		if(_delegate && [_delegate respondsToSelector:@selector(actionDidFinish:)]) {
			[_delegate actionDidFinish:self];
		}
		return;
	}
	
	NSURL * url = [_request URL];
	NSString * msurl = [NSString stringWithFormat:@"http://%@%@",[url host],[url path]];
	NSURL * murl = [NSURL URLWithString:msurl];
	window = [[UIApplication sharedApplication] keyWindow];
	mplayer = [[MPMoviePlayerViewController alloc] initWithContentURL:murl];
	[[mplayer moviePlayer] setControlStyle:MPMovieControlStyleFullscreen];
	[mplayer setWantsFullScreenLayout:TRUE];
	[mplayer setModalPresentationStyle:UIModalPresentationFullScreen];
	if(_delegate && [_delegate respondsToSelector:@selector(actionWantsToShowVideoTakeover:)]) {
		[_delegate actionWantsToShowVideoTakeover:self];
	}
	[_viewController setModalPresentationStyle:UIModalPresentationFullScreen];
	[_viewController setWantsFullScreenLayout:TRUE];
	[_viewController presentMoviePlayerViewControllerAnimated:mplayer];
	NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(finished)\
		name:MPMoviePlayerPlaybackDidFinishNotification object:[mplayer moviePlayer]];
#endif
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200

- (void) finished {
	if(_delegate && [_delegate respondsToSelector:@selector(updateFramesForV1Takeover)]) [_delegate updateFramesForV1Takeover];
	[_viewController dismissMoviePlayerViewControllerAnimated];
	[[UIApplication sharedApplication] setStatusBarHidden:TRUE];
}

#endif

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: VEActionVideo");
	#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self name:@"MPMoviePlayerPlaybackStateDidChangeNotification" object:[mplayer moviePlayer]];
#endif
	if(mplayer) {
		[mplayer release];
		mplayer = nil;
	}
	window = nil;
	[super dealloc];
}

@end
