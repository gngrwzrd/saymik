
#import "SMAdActionVideo.h"

@implementation SMAdActionVideo

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
		[self finish];
		return;
	}
	
	NSString * surl = [_message objectForKey:@"url"];
	if(!surl) surl = [_message objectForKey:@"href"];
	if(!surl) surl = [_message objectForKey:@"src"];
	if(!surl) {
		[self finish];
		return;
	}
	if([surl length] < 6) {
		[self finish];
		return;
	}
	if(_delegate && [_delegate respondsToSelector:@selector(actionWantsToShowVideoTakeover:)]) {
		[_delegate actionWantsToShowVideoTakeover:self];
	}
	NSURL * url = [NSURL URLWithString:surl];
	mplayer = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
	[[mplayer moviePlayer] setControlStyle:MPMovieControlStyleFullscreen];
	[mplayer setWantsFullScreenLayout:TRUE];
	[mplayer setModalPresentationStyle:UIModalPresentationFullScreen];
	[_viewController setModalPresentationStyle:UIModalPresentationFullScreen];
	[_viewController setWantsFullScreenLayout:TRUE];
	[_viewController presentMoviePlayerViewControllerAnimated:mplayer];
	NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(finished)\
				   name:MPMoviePlayerPlaybackDidFinishNotification object:[mplayer moviePlayer]];
	_beaconTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:true];
#endif
	
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200

- (void) finished {
	NSTimeInterval dur = ceil([[mplayer moviePlayer] duration]);
	[_beaconTimer invalidate];
	_beaconTimer = nil;
	
	SMAdVideoBeaconData * vb = NULL;
	NSString * fmt = [NSString stringWithString:@"%.0f"];
	NSDate * now = [NSDate date];
	NSMutableArray * beacons = [NSMutableArray array];
	NSMutableArray * sbeacon = [NSMutableArray array];
	NSString * nowstr = [NSString stringWithFormat:fmt,([now timeIntervalSince1970]*1000)];
	
	NSTimeInterval stT = 0;
	NSTimeInterval p25T = 0;
	NSTimeInterval p50T = 0;
	NSTimeInterval p75T = 0;
	NSTimeInterval p100T = 0;
	NSString * stCurtime = NULL;
	NSString * p100Curtime = NULL;
	NSString * p75Curtime = NULL;
	NSString * p50Curtime = NULL;
	NSString * p25Curtime = NULL;
	
	if(stEvent) stT = (NSTimeInterval)([stEvent timeIntervalSince1970]*1000);
	if(p25Event) p25T = (NSTimeInterval)([p25Event timeIntervalSince1970]*1000);
	if(p50Event) p50T = (NSTimeInterval)([p50Event timeIntervalSince1970]*1000);
	if(p75Event) p75T = (NSTimeInterval)([p75Event timeIntervalSince1970]*1000);
	if(p100Event) p100T = (NSTimeInterval)([p100Event timeIntervalSince1970]*1000);
	
	NSString * vidid = [[_message objectForKey:@"vidid"] copy];
	
	if(p100Event) {
		if(p100Event) p100Curtime = [[NSString alloc] initWithFormat:fmt,p100T];
		if(p75Event) p75Curtime = [[NSString alloc] initWithFormat:fmt,p75T];
		else p75Curtime = [nowstr copy];
		if(p50Event) p50Curtime = [[NSString alloc] initWithFormat:fmt,p50T];
		else p50Curtime = [nowstr copy];
		if(p25Event) p25Curtime = [[NSString alloc] initWithFormat:fmt,p25T];
		else p25Curtime = [nowstr copy];
		if(stEvent) stCurtime = [[NSString alloc] initWithFormat:fmt,stT];
		else stCurtime = [nowstr copy];
	}
	
	if(!p100Event && p75Event) {
		if(!p75Curtime) p75Curtime = [[NSString alloc] initWithFormat:fmt,p75T];
		if(p50Event) p50Curtime = [[NSString alloc] initWithFormat:fmt,p50T];
		else p50Curtime = [nowstr copy];
		if(p25Event) p25Curtime = [[NSString alloc] initWithFormat:fmt,p25T];
		else p25Curtime = [nowstr copy];
		if(stEvent) stCurtime = [[NSString alloc] initWithFormat:fmt,stT];
		else stCurtime = [nowstr copy];
	}
	
	if(!p100Event && !p75Event && p50Event) {
		if(!p50Curtime) p50Curtime = [[NSString alloc] initWithFormat:fmt,p50T];
		if(p25Event) p25Curtime = [[NSString alloc] initWithFormat:fmt,p25T];
		else p25Curtime = [nowstr copy];
		if(stEvent) stCurtime = [[NSString alloc] initWithFormat:fmt,stT];
		else stCurtime = [nowstr copy];
	}
	
	if(!p100Event && !p75Event && !p50Event && p25Event) {
		if(!p25Curtime) p25Curtime = [[NSString alloc] initWithFormat:fmt,p25T];
		if(stEvent) stCurtime = [[NSString alloc] initWithFormat:fmt,stT];
		else stCurtime = [nowstr copy];
	}
	
	if(!p100Event && !p75Event && !p50Event && !p25Event && stEvent) {
		if(!stCurtime) stCurtime = [[NSString alloc] initWithFormat:fmt,stT];
	}
	
	if(stCurtime) {
		vb = [[SMAdVideoBeaconData alloc] init];
		[vb setVidid:vidid];
		[vb setCurtime:stCurtime];
		[sbeacon addObject:vb];
		[vb release];
	}
	
	if(p25Curtime) {
		vb = [[SMAdVideoBeaconData alloc] init];
		[vb setCurtime:p25Curtime];
		[vb setVidid:vidid];
		[vb setVideoPercent:25];
		[vb setTimeInVideo:((NSUInteger)ceil((float)dur*.25))*1000];
		[beacons addObject:vb];
		[vb release];
	}
	
	if(p50Curtime) {
		vb = [[SMAdVideoBeaconData alloc] init];
		[vb setCurtime:p50Curtime];
		[vb setVidid:vidid];
		[vb setVideoPercent:50];
		[vb setTimeInVideo:((NSUInteger)ceil((float)dur*.50))*1000];
		[beacons addObject:vb];
		[vb release];
	}
	
	if(p75Curtime) {
		vb = [[SMAdVideoBeaconData alloc] init];
		[vb setCurtime:p75Curtime];
		[vb setVidid:vidid];
		[vb setVideoPercent:75];
		[vb setTimeInVideo:((NSUInteger)ceil((float)dur*.75))*1000];
		[beacons addObject:vb];
		[vb release];
	}
	
	if(p100Curtime) {
		vb = [[SMAdVideoBeaconData alloc] init];
		[vb setCurtime:p100Curtime];
		[vb setVidid:vidid];
		[vb setVideoPercent:100];
		[vb setTimeInVideo:(((NSUInteger)ceil(dur))-1)*1000];
		[beacons addObject:vb];
		[vb release];
	}
	
	if(stEvent && _delegate && \
	   [_delegate respondsToSelector:@selector(action:wantsToFireVideoStartBeacon:)])
	{
		[_delegate action:self wantsToFireVideoStartBeacon:sbeacon];
	}
	
	if((p25Event || p50Event || p75Event || p100Event) && _delegate && \
	   [_delegate respondsToSelector:@selector(action:wantsToFireVideoBeacons:)])
	{
		[_delegate action:self wantsToFireVideoBeacons:beacons];
	}
	
	if(_delegate && [_delegate respondsToSelector:@selector(actionDidFinishVideo:)]) {
		[_delegate actionDidFinishVideo:self];
	}
	
	[vidid release];
	[stCurtime release];
	[p25Curtime release];
	[p50Curtime release];
	[p75Curtime release];
	[p100Curtime release];
	
	[_viewController dismissMoviePlayerViewControllerAnimated];
	//[_viewController dismissModalViewControllerAnimated:FALSE];
}

- (void) update {
	MPMoviePlaybackState state = [[mplayer moviePlayer] playbackState];
	NSTimeInterval cur = [[mplayer moviePlayer] currentPlaybackTime];
	NSTimeInterval dur = ceil([[mplayer moviePlayer] duration])-1;
	if(state != 1) return;
	float c = ceil(cur)-1;
	float _p25 = ceil((float)dur*.25)-1;
	float _p50 = ceil((float)dur*.50)-1;
	float _p75 = ceil((float)dur*.75)-1;
	float _p100 = dur-1;
	if(c > 0 && !stEvent) stEvent = [[NSDate date] retain];
	if(c >=_p25 && !p25Event) p25Event = [[NSDate date] retain];
	if(c >= _p50 && !p50Event) p50Event = [[NSDate date] retain];
	if(c >= _p75 && !p75Event) p75Event = [[NSDate date] retain];
	if(c >= _p100 && !p100Event) p100Event = [[NSDate date] retain];
}

#endif

- (void) dealloc {

#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionVideo");
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self name:@"MPMoviePlayerPlaybackStateDidChangeNotification" object:[mplayer moviePlayer]];
	[center removeObserver:self name:@"MPMoviePlayerPlaybackDidFinishNotification" object:[mplayer moviePlayer]];
#endif
	
	if(stEvent) [stEvent release];
	if(p25Event) [p25Event release];
	if(p50Event) [p50Event release];
	if(p75Event) [p75Event release];
	if(p100Event) [p100Event release];
	stEvent = nil;
	p25Event = nil;
	p50Event = nil;
	p75Event = nil;
	p100Event = nil;
	if(_beaconTimer) [_beaconTimer invalidate];
	_beaconTimer = nil;
	if(webview) {
		[webview release];
		webview = nil;
	}
	if(mplayer) {
		[mplayer release];
		mplayer = nil;
	}
	window = nil;
	[super dealloc];
}

@end
