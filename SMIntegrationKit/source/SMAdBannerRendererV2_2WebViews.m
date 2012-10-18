
#import "SMAdBannerRendererV2_2WebViews.h"

@implementation SMAdBannerRendererV2_2WebViews

- (id) init {
	if(!(self = [super init])) return nil;
	CGRect tvf = {0,0,1,1};
	Boolean isphone = ![SMAdUtility isPad];
	isportrait = true;
	hasEngaged = false;
	isInTakeover = false;
	didHaveStatusbar = false;
	accel = [UIAccelerometer sharedAccelerometer];
	_mainScreen = [UIScreen mainScreen];
	_touchView = [[SMAdTouchView alloc] initWithFrame:tvf];
	_takeoverWindow = [[UIWindow alloc] initWithFrame:_mainScreen.bounds];
	_container = [[UIView alloc] initWithFrame:tvf];
	_containervc = [[UIViewController alloc] init];
	_tpbs = [[NSMutableArray alloc] init];
	_takeover = [[UIWebView alloc] initWithFrame:tvf];
	_black = [[UIView alloc] initWithFrame:CGRectMake(0,0,1,1)];
	[_black setBackgroundColor:[UIColor blackColor]];
	if(isphone) {
		_device_rotate_right = 160;
		_device_rotate_left = -160;
		_inv_port_height = 50;
		_inv_land_height = 32;
	} else {
		_device_rotate_right = 256;
		_device_rotate_left = -256;
		_inv_land_height = 66;
		_inv_port_height = 66;
	}
	_device_width = [_mainScreen bounds].size.width;
	_device_height = [_mainScreen bounds].size.height;
	[_containervc setView:_container];
	[_touchView setTouchUpInside:true];
	[_touchView setDelegate:self];
	return self;
}

- (void) updateFramesForInvite {
	CGRect touchFrame = {0};
	CGRect webViewFrame = {0};
	CGRect contentRect = {0};
	CGAffineTransform final_transform = CGAffineTransformIdentity;
	
	//portrait iphone,ipad
	if(isportrait && invitePortrait) {
		webViewFrame = CGRectMake(0,0,_device_width,_inv_port_height);
		touchFrame = CGRectMake(0,0,_device_width,_inv_port_height);
	}
	
	//landscape iphone, ipad
	if(!isportrait && inviteLandscape) {
		webViewFrame = CGRectMake(0,0,_device_height,_inv_land_height);
		touchFrame = CGRectMake(0,0,_device_height,_inv_land_height);
	}
	
	//portrait only invite, but in landscape. center the invite.
	if(!isportrait && !inviteLandscape && invitePortrait) {
		webViewFrame = CGRectMake((_device_height-_device_width)/2,0,_device_height,_inv_port_height);
		touchFrame = CGRectMake((_device_height-_device_width)/2,0,_device_height,_inv_port_height);
	}
	
	//set frames, transforms, etc
	[_container setTransform:final_transform];
	[_container setBounds:contentRect];
	[_webview setFrame:webViewFrame];
	[_touchView setFrame:touchFrame];
	
	//update ad content
	if(isportrait && invitePortrait) {
		[_webview stringByEvaluatingJavaScriptFromString:@"showInvitePortrait()"];
		[_webview stringByEvaluatingJavaScriptFromString:@"portrait()"];
	} else if(!isportrait && inviteLandscape) {
		[_webview stringByEvaluatingJavaScriptFromString:@"showInviteLandscape()"];
		[_webview stringByEvaluatingJavaScriptFromString:@"landscape()"];
	} else {
		[_webview stringByEvaluatingJavaScriptFromString:@"showInvitePortrait()"];
		[_webview stringByEvaluatingJavaScriptFromString:@"portrait()"];
	}
}

- (void) updateFramesForTakeover {
	CGRect webViewFrame = {0};
	CGRect containerFrame = {0};
	CGRect contentRect = {0};
	CGRect blackFrame = {0};
	CGAffineTransform transform = CGAffineTransformIdentity;
	Boolean rotateLeft = false;
	Boolean rotateRight = false;
	
	//reset container transform
	[_container setTransform:transform];
	
	//portrait iphone,ipad
	if(takeoverPortrait && isportrait) {
		//reset container
		contentRect = CGRectMake(0,0,_device_width,_device_height);
		[_container setTransform:transform];
		[_container setBounds:contentRect];
		
		//set frames
		containerFrame = CGRectMake(0,0,_device_width,_device_height);
		webViewFrame = CGRectMake(0,0,_device_width,_device_height);
		blackFrame = CGRectMake(0,0,_device_width,_device_height);
	}
	
	//portrait upside down iphone,ipad
	if(takeoverPortrait && isportrait && _orientation == UIDeviceOrientationPortraitUpsideDown) {
		//rotate 180
		transform = CGAffineTransformMakeRotation(degreesToRadians(180));
		contentRect = CGRectMake(0,0,_device_height,_device_width);
		[_container setBounds:contentRect];
		[_container setTransform:transform];
		
		//set frames
		containerFrame = CGRectMake(0,0,_device_width,_device_height);
		webViewFrame = CGRectMake(0,0,_device_width,_device_height);
		blackFrame = CGRectMake(0,0,_device_width,_device_height);
	}
	
	//landscape iphone,ipad
	if(takeoverLandscape && !isportrait) {
		//rotate
		if(_orientation == UIDeviceOrientationLandscapeLeft) rotateLeft = true;
		else rotateRight = true;
		
		//set frames
		containerFrame = CGRectMake(0,0,_device_height,_device_width);
		webViewFrame = CGRectMake(0,0,_device_height,_device_width);
		blackFrame = CGRectMake(0,0,_device_height,_device_width);
	}
	
	//check for landscape only case when in portrait
	if(isportrait && !takeoverPortrait && takeoverLandscape) {
		//rotate
		transform = CGAffineTransformMakeRotation(-3.14159/2);
		contentRect = CGRectMake(_device_rotate_right,0,_device_height,_device_width);
		
		//set container bounds and transform
		[_container setBounds:contentRect];
		[_container setTransform:transform];
		
		//set frames
		containerFrame = CGRectMake(0,0,_device_height,_device_width);
		webViewFrame = CGRectMake(0,0,_device_height,_device_width);
		blackFrame = CGRectMake(0,0,_device_height,_device_width);
	}
	
	//check for landscape only case when in landscape
	if(!isportrait && !takeoverPortrait && takeoverLandscape) {
		//rotate
		if(_orientation == UIDeviceOrientationLandscapeLeft) rotateLeft = true;
		else rotateRight = true;
		
		//set frames
		containerFrame = CGRectMake(0,0,_device_height,_device_width);
		webViewFrame = CGRectMake(0,0,_device_height,_device_width);
		blackFrame = CGRectMake(0,0,_device_height,_device_width);
	}
	
	//default to portrait if in landscape but don't have landscape
	if(!isportrait && !takeoverLandscape) {
		transform = CGAffineTransformIdentity;
		containerFrame = CGRectMake(0,0,_device_width,_device_height);
		webViewFrame = CGRectMake(0,0,_device_width,_device_height);
		blackFrame = CGRectMake(0,0,_device_width,_device_height);
		[_container setTransform:transform];
	}
	
	//check for portrait with landscape artwork. if it's the case, and
	//the current orientation is landscape left, it means we're upside down.
	//so rotate it 180 degrees to normal
	if(!isportrait && takeoverPortrait && artworkIsLandscape && \
	   _orientation == UIDeviceOrientationLandscapeLeft)
	{
		transform = CGAffineTransformMakeRotation(degreesToRadians(180));
		contentRect = CGRectMake(0,0,_device_height,_device_width);
		[_container setBounds:contentRect];
		[_container setTransform:transform];
	}
	
	//rotate left
	if(rotateLeft) {
		transform = CGAffineTransformMakeRotation(3.14159/2);
		contentRect = CGRectMake(0,_device_rotate_left,_device_height,_device_width);
		[_container setBounds:contentRect];
		[_container setTransform:transform];
	}
	
	//rotate right
	if(rotateRight) {
		transform = CGAffineTransformMakeRotation(-3.14159/2);
		contentRect = CGRectMake(_device_rotate_right,0,_device_height,_device_width);
		[_container setBounds:contentRect];
		[_container setTransform:transform];
	}
	
	//set frames, transforms, etc
	[_takeover setFrame:webViewFrame];
	[_container setFrame:containerFrame];
	[_black setFrame:blackFrame];
	
	//update ad content
	if(isportrait && takeoverPortrait) [_takeover stringByEvaluatingJavaScriptFromString:@"showTakeoverPortrait()"];
	else if(!isportrait && takeoverLandscape) [_takeover stringByEvaluatingJavaScriptFromString:@"showTakeoverLandscape()"];
	else if(isportrait && !takeoverPortrait && takeoverLandscape) [_takeover stringByEvaluatingJavaScriptFromString:@"showTakeoverLandscape()"];
	else if(!isportrait && !takeoverLandscape) [_takeover stringByEvaluatingJavaScriptFromString:@"showTakeoverPortrait()"];
	else [_takeover stringByEvaluatingJavaScriptFromString:@"showTakeoverPortrait()"];
}

- (void) render {
	//check if we have a view to render in
	if(!_view) {
		if([_ad respondsToSelector:@selector(_adNotAvailable)]) {
			[_ad performSelector:@selector(_adNotAvailable)];
		}
		return;
	}
	
	//update vars
	_webview = [_inspector webview];
	_keyWindow = [[self getKeyWindow] retain];
	invitePortrait = [_inspector inviteOrientationPortrait];
	inviteLandscape = [_inspector inviteOrientationLandscape];
	takeoverPortrait = [_inspector takeoverOrientationPortrait];
	takeoverLandscape = [_inspector takeoverOrientationLandscape];
	artworkIsLandscape = [_inspector artworkIsLandscape];
	
	//load content into takeover
	[_takeover loadHTMLString:[_inspector adcontent] baseURL:[NSURL URLWithString:[_loader adpath]]];
	
	//tell add it's been displayed
	[_inspector adWasShown];
	
	//check that the ad supports either landscape or portrait for invite & takeover
	if((!invitePortrait && !inviteLandscape) || \
	   (!takeoverPortrait && !takeoverLandscape))
	{
		if([_ad respondsToSelector:@selector(_adNotAvailable)]) {
			[_ad performSelector:@selector(_adNotAvailable)];
		}
		return;
	}
	
	//check that the ad targets ios family devices
	if(![_inspector isDeviceFamilyIOS]) {
		if(_ad && [_ad respondsToSelector:@selector(_adNotAvailable:)]) {
			[_ad performSelector:@selector(_adNotAvailable)];
			return;
		}
	}
	
	//check if a swipe should trigger new ad
	if([_model swipeForAdRequest]) {
		[_touchView setSwipeLeft:true];
		[_touchView setSwipeRight:true];
		[_touchView setSendEndIfSwiped:false];
	}
	
	//update network status if required
	if([_inspector requiresNetworkStatus]) {
		if(!_reach) _reach = [[Reachability reachabilityWithHostName:@"www.apple.com"] retain];
		NetworkStatus stat = [_reach currentReachabilityStatus];
		if(stat == NotReachable) [_inspector setModelValue:@"NotReachable" forKey:@"networkStatus"];
		if(stat == ReachableViaWiFi) [_inspector setModelValue:@"ReachableViaWiFi" forKey:@"networkStatus"];
		if(stat == ReachableViaWWAN) [_inspector setModelValue:@"ReachableViaWWAN" forKey:@"networkStatus"];
	}
	
	//update frames for invite
	[self updateFramesForInvite];
	
	//udpate invite webview
	NSObject * scroll = [[_webview subviews] lastObject];
	if([scroll respondsToSelector:@selector(setScrollEnabled:)]) {
		[(UIScrollView *)scroll setScrollEnabled:NO];
	}
	if([scroll respondsToSelector:@selector(setDelaysContentTouches:)]) {
		[(UIScrollView *)scroll setDelaysContentTouches:NO];
	}
	[_webview setDelegate:self];
	[_webview setOpaque:NO];
	[_webview setBackgroundColor:[UIColor clearColor]];
	
	//setAllowsInlineMediaPlayback, setMediaPlaybackRequiresUserAction requires >= 4.0
	if([_webview respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
		[_webview setAllowsInlineMediaPlayback:TRUE];
		[_webview setMediaPlaybackRequiresUserAction:FALSE];
	}
	
	//update takeover webview
	scroll = [[_takeover subviews] lastObject];
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
	if([_webview respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
		[_webview setAllowsInlineMediaPlayback:TRUE];
		[_webview setMediaPlaybackRequiresUserAction:FALSE];
	}
	
	//attach views
	if(![_inspector disableInviteTouchView]) [_webview addSubview:_touchView];
	[_view addSubview:_webview];
	
	//send beacons. If the ad can't send session beacons (init, echo,
	//admodelreceived) then the SDK sends it. Otherwise they come from
	//the javascript API.
	if(![_inspector canSendSessionBeacons]) {
		[self prepareBeacons];
		[_initBeacon sendInit];
		[_amrBeacon sendAdModelReceived];
		[_echoBeacon sendEcho];
		//[_inspector sendBannerShownBeacon];
	}
	
	//send delegate shown notification
	if(_adDelegate && [_adDelegate respondsToSelector:@selector(smAdBannerShown:)]) {
		[_adDelegate smAdBannerShown:_ad];
	}
	
	//check for hardware events
	if([_inspector requiresAccelerometerEvents] || [_inspector requiresShakeEvents]) {
		if([accel delegate] && [accel delegate] != self && accelDelegate != self) {
			accelDelegate = [accel delegate];
		}
		[accel setDelegate:self];
	}
}

- (void) showTakeover {
	//vars
	isInTakeover = true;
	SMAdIPrivate * pad = (SMAdIPrivate *)_ad;
	if(_keyWindow) [_keyWindow release];
	_keyWindow = [[self getKeyWindow] retain];
	didHaveStatusbar = ![[UIApplication sharedApplication] isStatusBarHidden];
	
	//pause auto updating if it's on
	[_ad pauseAutoUpdateBannerAds];
	
	//setup view hierarchy and frames
	[_container addSubview:_takeover];
	[self updateFramesForTakeover];
	
	//setup frames for animation
	CGRect sc = [[UIScreen mainScreen] bounds];
	CGRect cf = [_container frame];
	CGRect cf2 = [_container frame];
	cf.origin.y = sc.size.height;
	cf2.origin.y = 0;
	[_container setFrame:cf];
	
	//update network status if required
	if([_inspector requiresNetworkStatus]) {
		if(!_reach) _reach = [[Reachability reachabilityWithHostName:@"www.apple.com"] retain];
		NetworkStatus stat = [_reach currentReachabilityStatus];
		if(stat == NotReachable) [_inspector setModelValue:@"NotReachable" forKey:@"networkStatus"];
		if(stat == ReachableViaWiFi) [_inspector setModelValue:@"ReachableViaWiFi" forKey:@"networkStatus"];
		if(stat == ReachableViaWWAN) [_inspector setModelValue:@"ReachableViaWWAN" forKey:@"networkStatus"];
	}
	
	//bring in window and view
	[_takeoverWindow addSubview:_container];
	[_takeoverWindow makeKeyAndVisible];
	
	//animate it
	[UIView beginAnimations:@"showTakeover" context:nil];
	[UIView setAnimationDuration:[pad defaultAnimationDuration]];
	[UIView setAnimationDelegate:self];
	[_container setFrame:cf2];
	[UIView	commitAnimations];
	
	//hide status bar if it's there
	if(didHaveStatusbar) {
		NSTimeInterval ti = [pad defaultAnimationDuration]-.02;
		[NSTimer scheduledTimerWithTimeInterval:ti target:self
			selector:@selector(hideStatusbar) userInfo:nil repeats:false];
	}
	
	//tell the delegate the invite is shown
	if(_adDelegate && [_adDelegate respondsToSelector:@selector(smAdBannerTakeoverShown:)]) {
		[_adDelegate smAdBannerTakeoverShown:_ad];
	}
	
	//check for hardware events - update the delegate if required
	if([_inspector requiresAccelerometerEvents] || [_inspector requiresShakeEvents]) {
		if([accel delegate] && [accel delegate] != self && accelDelegate != self) {
			accelDelegate = [accel delegate];
		}
		[accel setDelegate:self];
	}
	
	//set the view on the view controller for video
	[_containervc setView:_container];
}

- (void) closeTakeoverAnimated:(Boolean) animated {
	if(![_takeoverWindow isKeyWindow]) return;
	
	SMAdIPrivate * pad = (SMAdIPrivate *)_ad;
	
	//notify of hiding
	if(_adDelegate && [_adDelegate respondsToSelector:@selector(smAdBannerTakeoverWillHide:)]) {
		[_adDelegate smAdBannerTakeoverWillHide:_ad];
	}
	
	//show status bar if it was there
	if(didHaveStatusbar) [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
	
	//setup animation frames
	CGRect cf = [_container frame];
	cf.origin.y = [[UIScreen mainScreen] bounds].size.height;
	
	//animate it out
	if(animated) {
		[UIView beginAnimations:@"closeTakeover" context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(closeTakeoverFinished)];
		[_container setFrame:cf];
		[UIView setAnimationDuration:[pad defaultAnimationDuration]];
		[UIView commitAnimations];
	} else {
		[self closeTakeoverFinished];
	}
}

- (void) closeTakeoverFinished {
	//restart auto updating ads if they're on
	[_ad restartAutoUpdating];
	
	//remove and release temp vars
	[_container removeFromSuperview];
	[_keyWindow makeKeyAndVisible];
	[_keyWindow release];
	_keyWindow = nil;
	
	//reset the y coordinate for container
	CGRect cf = [_container frame];
	cf.origin.y = 0;
	[_container setFrame:cf];
	
	//tell the delegate the invite is hidden
	if(_adDelegate && [_adDelegate respondsToSelector:@selector(smAdBannerTakeoverHidden:)]) {
		[_adDelegate smAdBannerTakeoverHidden:_ad];
	}
	
	//reset to banner view
	[self updateFramesForInvite];
	[_view addSubview:_webview];
	[_webview stringByEvaluatingJavaScriptFromString:@"reset()"];
	if(isportrait) {
		[_webview stringByEvaluatingJavaScriptFromString:@"showInvitePortrait()"];
		[_webview stringByEvaluatingJavaScriptFromString:@"portrait()"];
	} else {
		[_webview stringByEvaluatingJavaScriptFromString:@"showInviteLandscape()"];
		[_webview stringByEvaluatingJavaScriptFromString:@"landscape()"];
	}
	
	//clear the view on the container view controller. it needs to be cleared
	//so animations work as expected. when the view controller owns the view
	//it messes up other animations.
	[_containervc setView:nil];
	
	//not in takeover anymore
	isInTakeover = false;
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
		[_webview stringByEvaluatingJavaScriptFromString:jse];
		[_takeover stringByEvaluatingJavaScriptFromString:jse];
	}
	
	//detect shakes
	NSString * shakeName = [_inspector shakeFunctionName];
	if([_inspector requiresShakeEvents] && shakeName) {
		NSString * jse = [NSString stringWithFormat:@"%@()",shakeName];
		if(!isShaking && accelerometerIsShaking(last,acceleration,.7)) {
			isShaking = true;
			[_webview stringByEvaluatingJavaScriptFromString:jse];
			[_takeover stringByEvaluatingJavaScriptFromString:jse];
		} else if(isShaking && !accelerometerIsShaking(last,acceleration,.7)) {
			isShaking = false;
		}
		if(last) [last release];
		last = [acceleration retain];
	}
	
	if(accelDelegate) [accelDelegate accelerometer:accelerometer didAccelerate:acceleration];
}

- (void)
view:(SMAdTouchView *) view didEndTouches:(NSSet *) touches
event:(UIEvent *) event
{
	//send first touch beacons
	if(!hasEngaged) {
		[_inspector sendEngagedBeacon];
		hasEngaged = true;
	}
	
	//show takeover
	[self showTakeover];
}

- (void)
view:(SMAdTouchView *)view didSwipeLeft:(NSSet *)touches
event:(UIEvent *)event {
	[_ad requestBanner];
}

- (void)
view:(SMAdTouchView *)view didSwipeRight:(NSSet *)touches
event:(UIEvent *)event {
	[_ad requestBanner];
}

- (BOOL)
webView:(UIWebView *) webView shouldStartLoadWithRequest:(NSURLRequest *) req
navigationType:(UIWebViewNavigationType) navType
{
	if([[[req URL] absoluteString] isEqualToString:[[[_webview request] URL] absoluteString]]) {
		return true;
	}
	UIWebView * target = _webview;
	SMAdActionBase * action = [[SMActionHandler createActionWithRenderer:self
		webview:target request:req navType:navType] retain];
	if(!action) return TRUE;
	BOOL ret = [action returnForUIWebView];
	[action setViewController:_containervc];
	[action setModel:_model];
	if([action requiresPersistence]) [_actions addObject:action];
	[action execute];
	[action autorelease];
	return ret;
}

- (void) setOrientation:(UIDeviceOrientation) orientation updateFrames:(Boolean) update {
	Boolean diff = orientation != _orientation;
	isportrait = false;
	_orientation = orientation;
	if(UIDeviceOrientationIsPortrait(orientation)) isportrait = true;
	if(update) {
		if(isInTakeover) [self updateFramesForTakeover];
		else [self updateFramesForInvite];
	}
	if(!isInTakeover && diff && update) [_inspector sendBannerShownBeacon];
}

- (Boolean) supportsOrientation:(UIDeviceOrientation) orientation {
	if(UIDeviceOrientationIsLandscape(orientation) && inviteLandscape) return true;
	if(UIDeviceOrientationIsPortrait(orientation) && invitePortrait) return true;
	if(UIDeviceOrientationIsLandscape(orientation) && !isInTakeover) return true;
	return false;
}

- (void) appBackground {
	//tell the ad we're going inactive
	[_inspector adBecameInactive];
	_backgroundEvent = [[NSDate date] retain];
}

- (void) appForeground {
	if(!isInTakeover) return;
	
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

- (void) hideStatusbar {
	[[UIApplication sharedApplication] setStatusBarHidden:TRUE];
}

- (void) hideModals {
	[self closeTakeoverAnimated:false];
}

- (void) closeTakeover {
	[self closeTakeoverAnimated:true];
}

- (void) actionDidCloseTakeover:(SMAdActionBase <SMAdAction>*) action {
	[self closeTakeoverAnimated:false];
}

- (void) actionWantsToShowVideoTakeover:(SMAdActionBase <SMAdAction> *) action {
	[_keyWindow addSubview:_black];
}

- (void) actionDidFinishVideo:(SMAdActionBase <SMAdAction> *) action {
	[_black removeFromSuperview];
}

- (void) actionWantsToCloseTakeover:(SMAdActionBase <SMAdAction>*) action {
	[self closeTakeoverAnimated:true];
}

- (void) actionWantsToShowTakeover:(SMAdActionBase <SMAdAction>*) action {
	[self showTakeover];
}

- (void) action:(SMAdActionBase <SMAdAction>*) action wantsToFireVideoStartBeacon:(NSMutableArray *) beaconInfo {
	SMAdVideoBeaconData * beacon = [beaconInfo objectAtIndex:0];
	[_inspector sendVideoStartWithCurtime:[beacon curtime] andVidId:[beacon vidid]];
}

- (void) action:(SMAdActionBase <SMAdAction>*) action wantsToFireVideoBeacons:(NSMutableArray *) beaconInfo {
	SMAdVideoBeaconData * beacon = NULL;
	NSUInteger i = 0;
	NSUInteger c = [beaconInfo count];
	for(i=0;i<c;i++) {
		beacon = [beaconInfo objectAtIndex:i];
		[_inspector sendTimeInVideoWithCurtime:[beacon curtime] \
			vidId:[beacon vidid] timeInVideo:[beacon timeInVideo] videoPercent:[beacon videoPercent]];
	}
}

- (void) actionCantContinue:(SMAdActionBase <SMAdAction>*) action reason:(_SMAdError) reason {
	UIAlertView * alert = [[UIAlertView alloc] init];
	[alert addButtonWithTitle:@"OK"];
	if(reason == _SMAdErrorCantSendMail) {
		[alert setMessage:@"Please setup your email client to send email."];
		[alert show];
	}
	[alert autorelease];
}

- (Boolean) isVisible {
	if([_container superview] || [_webview superview]) return true;
	return false;
}

- (void) webViewDidFinishLoad:(UIWebView *) webView {}

- (void) teardown {
	//send close beacon
	if(![_inspector canSendSessionBeacons]) {
		[_inspector sendCloseBeaconForUIWebView:_webview];
	}
	
	//tell the ad it's being destroyed
	[_inspector adWasDestroyed];
	
	//remove views
	[_webview removeFromSuperview];
	if(_touchView) [_touchView removeFromSuperview];
	
	//kill actions
	[_actions release];
	_actions = nil;
	_actions = [[NSMutableArray alloc] init];
	
	//reset accelerometer
	if(accelDelegate) [accel setDelegate:accelDelegate];
	else if([accel delegate] == self) [accel setDelegate:nil];
	
	//wait slightly so that the send close beacon sends
	[NSTimer scheduledTimerWithTimeInterval:.2 target:self
		selector:@selector(finishTeardown) userInfo:nil repeats:false];
}

- (void) finishTeardown {
	if(_touchView) {
		[_touchView setDelegate:nil];
		[_touchView release];
	}
	_touchView = NULL;
	_webview = NULL;
	_deviceEventsTarget = NULL;
	_view = NULL;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdBannerRendererV2_2WebViews");
	#endif
	[last release];
	[_takeoverWindow release];
	[_keyWindow release];
	[_touchView release];
	[_container release];
	[_tpbs release];
	[_containervc release];
	[_reach release];
	[_takeover release];
	[_backgroundEvent release];
	[_black release];
	_black = nil;
	_backgroundEvent = nil;
	_takeover = nil;
	_reach = nil;
	_containervc = nil;
	last = nil;
	accelDelegate = nil;
	accel = nil;
	_tpbs = nil;
	_container = nil;
	_webview = nil;
	_takeoverWindow = nil;
	_keyWindow = nil;
	_webview = nil;
	_touchView = nil;
	_deviceEventsTarget = nil;
	_view = nil;
	[super dealloc];
}


@end
