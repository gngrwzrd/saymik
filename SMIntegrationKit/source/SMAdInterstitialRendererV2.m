
#import "SMAdInterstitialRendererV2.h"
#import "SMAd.h"

@implementation SMAdInterstitialRendererV2

- (id) init {
	if(!(self = [super init])) return nil;
	UIScreen * ms = [UIScreen mainScreen];
	Boolean isphone = ![SMAdUtility isPad];
	CGRect screen = [ms bounds];
	_mainScreen = [UIScreen mainScreen];
	didHaveStatusbar = false;
	hasEngaged = false;
	isportrait = true;
	if(isphone) {
		_device_rotate_right = 160;
		_device_rotate_left = -160;
	} else {
		_device_rotate_right = 256;
		_device_rotate_left = -256;
	}
	_device_width = [_mainScreen bounds].size.width;
	_device_height = [_mainScreen bounds].size.height;
	_container = [[UIView alloc] initWithFrame:CGRectMake(0,0,1,1)];
	_containervc = [[UIViewController alloc] init];
	_takeoverWindow = [[UIWindow alloc] initWithFrame:screen];
	_black = [[UIView alloc] initWithFrame:CGRectMake(0,0,1,1)];
	[_black setBackgroundColor:[UIColor blackColor]];
	accel = [UIAccelerometer sharedAccelerometer];
	[_containervc setView:_container];
	return self;
}

- (void) teardown {
	//reset accelerometer
	if(toredown) return;
	toredown = TRUE;
	if(accelDelegate) [accel setDelegate:accelDelegate];
	else if([accel delegate] == self) [accel setDelegate:nil];
	[_container release];
	[_takeoverWindow release];
	[_keyWindow release];
	_takeover = nil;
	_takeoverWindow = nil;
	_container = nil;
	_keyWindow = nil;
}

- (void) updateFrames {
	CGRect takeoverFrame = {0};
	CGRect containerFrame = {0};
	CGRect contentRect = {0};
	CGRect blackFrame = {0};
	CGAffineTransform transform = CGAffineTransformIdentity;
	Boolean rotateLeft = false;
	Boolean rotateRight = false;
	
	//reset container transform
	[_container setTransform:transform];
	
	//portrait iphone,ipad
	if(interstitialPortrait && isportrait) {
		if(_orientation == UIDeviceOrientationPortraitUpsideDown) {
			//if we're in portrait, but upside down, rotate 180
			transform = CGAffineTransformMakeRotation(degreesToRadians(180));
			contentRect = CGRectMake(0,0,_device_height,_device_width);
			[_container setBounds:contentRect];
			[_container setTransform:transform];
		} else {
			//reset rotation and bounds
			contentRect = CGRectMake(0,0,_device_width,_device_height);
			[_container setTransform:transform];
			[_container setBounds:contentRect];
		}
		
		//set frames
		containerFrame = CGRectMake(0,0,_device_width,_device_height);
		takeoverFrame = CGRectMake(0,0,_device_width,_device_height);
		blackFrame = CGRectMake(0,0,_device_width,_device_height);
	}
	
	//landscape iphone,ipad
	if(interstitialLandscape && !isportrait) {
		//rotate
		if(_orientation == UIDeviceOrientationLandscapeLeft) rotateLeft = true;
		else rotateRight = true;
		
		//set frames
		containerFrame = CGRectMake(0,0,_device_height,_device_width);
		takeoverFrame = CGRectMake(0,0,_device_height,_device_width);
		blackFrame = CGRectMake(0,0,_device_height,_device_width);
	}
	
	//check for landscape only case when in portrait
	if(isportrait && !interstitialPortrait && interstitialLandscape) {
		//rotate
		transform = CGAffineTransformMakeRotation(-3.14159/2);
		contentRect = CGRectMake(_device_rotate_right,0,_device_height,_device_width);
		
		//set container bounds and transform
		[_container setBounds:contentRect];
		[_container setTransform:transform];
		
		//set frames
		containerFrame = CGRectMake(0,0,_device_height,_device_width);
		takeoverFrame = CGRectMake(0,0,_device_height,_device_width);
		blackFrame = CGRectMake(0,0,_device_height,_device_width);
	}
	
	//check for landscape only case when in landscape
	if(!isportrait && !interstitialPortrait && interstitialLandscape) {
		//rotate
		if(_orientation == UIDeviceOrientationLandscapeLeft) rotateLeft = true;
		else rotateRight = true;
		
		//set frames
		containerFrame = CGRectMake(0,0,_device_height,_device_width);
		takeoverFrame = CGRectMake(0,0,_device_height,_device_width);
		blackFrame = CGRectMake(0,0,_device_height,_device_width);
	}
	
	//default to portrait if in landscape but don't have landscape
	if(!isportrait && !interstitialLandscape) {
		transform = CGAffineTransformIdentity;
		containerFrame = CGRectMake(0,0,_device_width,_device_height);
		takeoverFrame = CGRectMake(0,0,_device_width,_device_height);
		blackFrame = CGRectMake(0,0,_device_width,_device_height);
		[_container setTransform:transform];
	}
	
	//check for portrait with landscape artwork. if it's the case, and
	//the current orientation is landscape left, it means we're upside down.
	//so rotate it 180 degrees to normal
	if(!isportrait && interstitialPortrait && artworkIsLandscape && \
	   _orientation == UIDeviceOrientationLandscapeLeft)
	{
		transform = CGAffineTransformMakeRotation(degreesToRadians(180));
		contentRect = CGRectMake(0,0,_device_height,_device_width);
		[_container setBounds:contentRect];
		[_container setTransform:transform];
	}
	
	if(rotateLeft) {
		transform = CGAffineTransformMakeRotation(3.14159/2);
		contentRect = CGRectMake(0,_device_rotate_left,_device_height,_device_width);
		[_container setBounds:contentRect];
		[_container setTransform:transform];
	}
	
	if(rotateRight) {
		transform = CGAffineTransformMakeRotation(-3.14159/2);
		contentRect = CGRectMake(_device_rotate_right,0,_device_height,_device_width);
		[_container setBounds:contentRect];
		[_container setTransform:transform];
	}
	
	//set frames, transforms, etc
	[_takeover setFrame:takeoverFrame];
	[_container setFrame:containerFrame];
	[_black setFrame:blackFrame];
	
	//update ad content
	if(isportrait && interstitialPortrait) [_takeover stringByEvaluatingJavaScriptFromString:@"showInterstitialPortrait()"];
	else if(!isportrait && interstitialLandscape) [_takeover stringByEvaluatingJavaScriptFromString:@"showInterstitialLandscape()"];
	else if(isportrait && !interstitialPortrait && interstitialLandscape) [_takeover stringByEvaluatingJavaScriptFromString:@"showInterstitialLandscape()"];
	else if(!isportrait && !interstitialLandscape) [_takeover stringByEvaluatingJavaScriptFromString:@"showInterstitialPortrait()"];
	else [_takeover stringByEvaluatingJavaScriptFromString:@"showInterstitialPortrait()"];
}

- (void) render {
	//vars
	UIApplication * app = [UIApplication sharedApplication];
	_takeover = [_inspector webview];
	_keyWindow = [[self getKeyWindow] retain];
	interstitialPortrait = [_inspector interstitialPortrait];
	interstitialLandscape = [_inspector interstitialLandscape];
	artworkIsLandscape = [_inspector artworkIsLandscape];
	didHaveStatusbar = ![app isStatusBarHidden];
	
	//check that the ad targets ios family devices
	if(![_inspector isDeviceFamilyIOS]) {
		if(_ad && [_ad respondsToSelector:@selector(_adNotAvailable:)]) {
			[_ad performSelector:@selector(_adNotAvailable)];
			return;
		}
	}
	
	//pause auto updating if it's on.
	//[_ad pauseAutoUpdateBannerAds];
	
	//tell add it's been displayed
	[_inspector adWasShown];
	
	//update network status if required
	if([_inspector requiresNetworkStatus]) {
		if(!_reach) _reach = [[Reachability reachabilityWithHostName:@"www.apple.com"] retain];
		NetworkStatus stat = [_reach currentReachabilityStatus];
		if(stat == NotReachable) [_inspector setModelValue:@"NotReachable" forKey:@"networkStatus"];
		if(stat == ReachableViaWiFi) [_inspector setModelValue:@"ReachableViaWiFi" forKey:@"networkStatus"];
		if(stat == ReachableViaWWAN) [_inspector setModelValue:@"ReachableViaWWAN" forKey:@"networkStatus"];
	}
	
	//update takeover
	NSObject * scroll = [[_takeover subviews] lastObject];
	if([scroll respondsToSelector:@selector(setScrollEnabled:)]) {
		[(UIScrollView *)scroll setScrollEnabled:NO];
	}
	if([scroll respondsToSelector:@selector(setDelaysContentTouches:)]) {
		[(UIScrollView *)scroll setDelaysContentTouches:NO];
	}
	[_takeover setDelegate:self];
	[_takeover setOpaque:NO];
	[_takeover setBackgroundColor:[UIColor clearColor]];
	
	//setAllowsInlineMediaPlayback, setMediaPlaybackRequiresUserAction requires >= 4.0
	if([_takeover respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
		[_takeover setAllowsInlineMediaPlayback:TRUE];
		[_takeover setMediaPlaybackRequiresUserAction:FALSE];
	}
	
	//update frames
	[self updateFrames];
	
	//set frame for animation
	CGRect cf = [_container frame];
	CGRect cf2 = [_container frame];
	cf.origin.y = [[UIScreen mainScreen] bounds].size.height;
	[_container setFrame:cf];
	
	//attach everything
	[_container addSubview:_takeover];
	[_takeoverWindow addSubview:_container];
	[_takeoverWindow makeKeyAndVisible];
	
	//send beacons. If the ad can't send session beacons (init, echo,
	//admodelreceived) then the SDK sends it. Otherwise they come from
	//the javascript API.
	if(![_inspector canSendSessionBeacons]) {
		[self prepareBeacons];
		[_initBeacon sendInit];
		[_amrBeacon sendAdModelReceived];
		[_echoBeacon sendEcho];
	}
	
	//animate in
	[UIView beginAnimations:@"showInterstitial" context:nil];
	[UIView setAnimationDuration:[(SMAdIPrivate *)_ad defaultAnimationDuration]];
	[UIView setAnimationDelegate:self];
	[_container setFrame:cf2];
	[UIView commitAnimations];
	
	//hide status bar if it's there.
	if(didHaveStatusbar) {
		NSTimeInterval ti = [(SMAdIPrivate *)_ad defaultAnimationDuration]-.02;
		[NSTimer scheduledTimerWithTimeInterval:ti target:self
			selector:@selector(hideStatusBar) userInfo:nil repeats:false];
	}
	
	//send shown delegate and notification
	if(_adDelegate && [_adDelegate respondsToSelector:@selector(smAdInterstitialShown:)]) {
		[_adDelegate smAdInterstitialShown:_ad];
	}
	
	//check for hardware events
	if([_inspector requiresAccelerometerEvents] || [_inspector requiresShakeEvents]) {
		if([accel delegate] && [accel delegate] != self && accelDelegate != self) {
			accelDelegate = [accel delegate];
		}
		[accel setDelegate:self];
	}
}

- (void) closeTakeover {
	//make sure we've got the key window
	if(![_takeoverWindow isKeyWindow]) return;
	
	SMAdIPrivate * pad = (SMAdIPrivate *)_ad;
	
	//show status bar
	if(didHaveStatusbar) [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
	
	//update frames for animation
	CGRect cf = [_container frame];
	cf.origin.y = [[UIScreen mainScreen] bounds].size.height;
	
	//animate out
	[UIView beginAnimations:@"closeTakeover" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(takeoverDidClose)];
	[UIView setAnimationDuration:[pad defaultAnimationDuration]];
	[_container setFrame:cf];
	[UIView commitAnimations];
	
	//reset accelerometer delegate
	if(accelDelegate) [accel setDelegate:accelDelegate];
	else if([accel delegate] == self) [accel setDelegate:nil];
}

- (void) takeoverDidClose {	
	//remove stuff
	[_container removeFromSuperview];
	[_keyWindow makeKeyAndVisible];
	[_keyWindow release];
	_keyWindow = nil;
	
	//update container frame
	CGRect cf = [_container frame];
	cf.origin.y = 0;
	[_container setFrame:cf];
	
	//send close beacon
	if(![_inspector canSendSessionBeacons]) {
		[_inspector sendCloseBeaconForUIWebView:_takeover];
	}
	
	//tell the ad it's being destroyed
	[_inspector adWasDestroyed];
	
	//send hidden delegate and notification
	if(_adDelegate && [_adDelegate respondsToSelector:@selector(smAdInterstitialHidden:)]) {
		[_adDelegate smAdInterstitialHidden:_ad];
	}
	
	//restart auto updating ads if they're on
	//[_ad restartAutoUpdating];
	
	//tear ourselves down
	[self teardown];
}

- (void) hideModals {
	return;
	[self closeTakeover];
}

- (void) appBackground {
	//tell the ad we're going inactive
	[_inspector adBecameInactive];
	_backgroundEvent = [[NSDate date] retain];
}

- (void) appForeground {
	//tell the ad it became active.
	[_inspector adBecameActive];
	
	//if the ad can't send app focus beacons, do it from the SDK. otherwise
	//let the ad do it.
	if(![_inspector canSendAppFocusBeacons]) {
		NSDate * now = [NSDate date];
		NSTimeInterval ti = [_backgroundEvent timeIntervalSince1970] * 1000;
		NSTimeInterval n = [now timeIntervalSince1970] * 1000;
		[_inspector sendScreenHiddenBeaconWithCurtime:ti];
		[_inspector sendScreenShownBeaconWithCurtime:n];
	}
}

- (void) actionWantsToShowVideoTakeover:(SMAdActionBase <SMAdAction> *) action {
	[_keyWindow addSubview:_black];
}

- (void) actionDidFinishVideo:(SMAdActionBase <SMAdAction> *) action {
	[_black removeFromSuperview];
}

- (void) actionWantsToCloseTakeover:(SMAdActionBase <SMAdAction>*) action {
	[self closeTakeover];
}

- (void) actionDidCloseTakeover:(SMAdActionBase <SMAdAction>*) action {
	[self closeTakeover];
}

- (void) actionCantContinue:(SMAdActionBase <SMAdAction>*) action reason:(_SMAdError) reason {
	UIAlertView * alert = [[UIAlertView alloc] init];
	[alert addButtonWithTitle:@"OK"];
	if(reason == _SMAdErrorCantSendMail) {
		[alert setMessage:@"Please setup your email client to send email."];
	}
	[alert autorelease];
}

- (void) action:(SMAdActionBase <SMAdAction>*) action wantsToFireVideoStartBeacon:(NSMutableArray *) beaconInfo {
	SMAdVideoBeaconData * beacon = [beaconInfo objectAtIndex:0];
	[_inspector sendVideoStartWithCurtime:[beacon curtime] andVidId:[beacon vidid]];
}

- (void) action:(SMAdActionBase <SMAdAction>*) action wantsToFireVideoBeacons:(NSMutableArray *) beaconInfo {
	SMAdVideoBeaconData * beacon = NULL;
	NSUInteger i = 0;
	NSUInteger c = [beaconInfo count];
	for(;i<c;i++) {
		beacon = [beaconInfo objectAtIndex:i];
		[_inspector sendTimeInVideoWithCurtime:[beacon curtime] vidId:[beacon vidid] timeInVideo:[beacon timeInVideo] videoPercent:[beacon videoPercent]];
	}
}

- (void) hideStatusBar {
	[[UIApplication sharedApplication] setStatusBarHidden:TRUE];
}

- (Boolean) isVisible {
	return !([_takeover superview] == NULL);
}

- (void)
accelerometer:(UIAccelerometer *) accelerometer
didAccelerate:(UIAcceleration *) acceleration
{
	//accelerometer updates
	NSString * accelName = [_inspector accelerometerFunctionName];
	if([_inspector requiresAccelerometerEvents] && accelName) {
		NSString * js = [accelName stringByAppendingString:@"('%@','%@','%@')"];
		NSString * x = [NSString stringWithFormat:@"%0.3f",acceleration.x];
		NSString * y = [NSString stringWithFormat:@"%0.3f",acceleration.y];
		NSString * z = [NSString stringWithFormat:@"%0.3f",acceleration.z];
		NSString * jse = [NSString stringWithFormat:js,x,y,z];
		if([_container superview]) [_takeover stringByEvaluatingJavaScriptFromString:jse];
	}
	
	//detect shakes
	NSString * shakeName = [_inspector shakeFunctionName];
	if([_inspector requiresShakeEvents] && shakeName) {
		NSString * jse = [NSString stringWithFormat:@"%@()",shakeName];
		if(!isShaking && accelerometerIsShaking(last,acceleration,.7)) {
			isShaking = true;
			if([_container superview]) [_takeover stringByEvaluatingJavaScriptFromString:jse];
		} else if(isShaking && !accelerometerIsShaking(last,acceleration,.7)) {
			isShaking = false;
		}
		if(last) [last release];
		last = [acceleration retain];
	}
	
	if(accelDelegate) [accelDelegate accelerometer:accelerometer didAccelerate:acceleration];
}

- (Boolean) supportsOrientation:(UIDeviceOrientation) orientation {
	if(UIDeviceOrientationIsPortrait(orientation)) {
		if(interstitialPortrait) return true;
	}
	if(UIDeviceOrientationIsLandscape(orientation)) {
		if(interstitialLandscape) return true;
	}
	return false;
}

- (void) setOrientation:(UIDeviceOrientation) orientation updateFrames:(Boolean) update {
	isportrait = false;
	_orientation = orientation;
	if(UIDeviceOrientationIsPortrait(orientation)) isportrait = true;
	[self updateFrames];
}

- (BOOL)
webView:(UIWebView *) webView shouldStartLoadWithRequest:(NSURLRequest *) req
navigationType:(UIWebViewNavigationType) navType
{
	SMAdActionBase * action = [[SMActionHandler createActionWithRenderer:self
		webview:_takeover request:req navType:navType] retain];
	if(!action) return TRUE;
	BOOL ret = [action returnForUIWebView];
	[action setViewController:_containervc];
	[action setModel:_model];
	if([action requiresPersistence]) [_actions addObject:action];
	[action execute];
	[action autorelease];
	return ret;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdInterstitialRendererV2");
	#endif
	[_container release];
	[_containervc release];
	[_takeoverWindow release];
	[_keyWindow release];
	[_tpbs release];
	[_reach release];
	[_backgroundEvent release];
	[_black release];
	_black = nil;
	_backgroundEvent = nil;
	_reach = nil;
	_containervc = nil;
	accel = nil;
	accelDelegate = nil;
	_tpbs = nil;
	_takeover = nil;
	_takeoverWindow = nil;
	_container = nil;
	_keyWindow = nil;
	[super dealloc];
}


@end
