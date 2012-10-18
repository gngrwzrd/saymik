
#import "SMAdBannerRendererV1.h"

@implementation SMAdBannerRendererV1

- (id) init {
	if(!(self = [super init])) return nil;
	UIScreen * screen = [UIScreen mainScreen];
	CGRect tvf = {0,0,320,50};
	hasEngaged = false;
	isportrait = true;
	didHaveStatusbar = false;
	_touchView = [[SMAdTouchView alloc] initWithFrame:tvf];
	_takeover = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,320,480)];
	_takeoverWindow = [[UIWindow alloc] initWithFrame:screen.bounds];
	_container = [[UIView alloc] initWithFrame:CGRectMake(0,0,1,1)];
	_containervc = [[UIViewController alloc] init];
	[self setupToolbar];
	[_touchView setTouchUpInside:TRUE];
	[_touchView setDelegate:self];
	[_containervc setView:_container];
	return self;
}

- (void) setupToolbar {
	CGRect frame = {0,0,1,1};
	_toolbar = [[UIToolbar alloc] initWithFrame:frame];
	_toolbar.barStyle = UIBarStyleDefault;
	UIBarButtonItem * back = [[UIBarButtonItem alloc] initWithTitle:@"Return"
		style:UIBarButtonItemStyleDone target:self action:@selector(closeTakeover)];
	UILabel * branding = [[UILabel alloc] initWithFrame:CGRectMake(100,0,170,44)];
	branding.font = [branding.font fontWithSize:12.0f];
	branding.backgroundColor = [UIColor clearColor];
	branding.textColor = [UIColor grayColor];
	branding.shadowColor = [UIColor darkGrayColor];
	branding.shadowOffset = CGSizeMake(1, 1);
	branding.text = @"Powered by Say Media";
	NSArray * items = [NSArray arrayWithObject:back];
	[_toolbar setItems:items animated:NO];
	_toolbar.tintColor = [UIColor darkGrayColor];
	[_toolbar addSubview:branding];
	[branding release];
	[back release];
}

- (void) updateFramesForInvite {
	CGRect webViewFrame = {0};
	CGRect takeOverFrame = {0};
	CGRect toolbarFrame = {0};
	CGRect touchFrame = {0};
	CGRect containerFrame = {0};
	if(isportrait) webViewFrame = CGRectMake(10,0,320,50);
	else webViewFrame = CGRectMake(90,0,480,50);
	toolbarFrame = CGRectMake(0,0,320,44);
	takeOverFrame = CGRectMake(0,0,320,480);
	containerFrame = CGRectMake(0,0,320,480);
	touchFrame = CGRectMake(0,0,320,50);
	takeOverFrame.origin.y = 44;
	[_toolbar setFrame:toolbarFrame];
	[_webview setFrame:webViewFrame];
	[_touchView setFrame:touchFrame];
	[_container setFrame:containerFrame];
}

- (void) updateFramesForV1Takeover {
	[self updateFramesForTakeover];
}

- (void) updateFramesForTakeover {
	CGRect takeOverFrame = {0};
	CGRect containerFrame = {0};
	takeOverFrame = CGRectMake(0,0,320,480);
	containerFrame = CGRectMake(0,0,320,480);
	takeOverFrame.origin.y = 44;
	[_takeover setFrame:takeOverFrame];
	[_container setFrame:containerFrame];
}

- (void) teardown {
	//send close beacon
	[_inspector sendCloseBeaconForUIWebView:_webview];
	
	//restart auto updating ads if they're on
	[_ad restartAutoUpdating];
	
	//remove and release temp vars
	[_toolbar removeFromSuperview];
	[_container removeFromSuperview];
	[_takeover removeFromSuperview];
	[_keyWindow makeKeyAndVisible];
	[_keyWindow release];
	_keyWindow = nil;
	
	//remove view
	[_webview removeFromSuperview];
	if(_touchView) [_touchView removeFromSuperview];
	
	//wait slightly so that the send close beacon sends
	[NSTimer scheduledTimerWithTimeInterval:.2 target:self
		selector:@selector(finishTeardown) userInfo:nil repeats:false];
	
	//kill actions
	[_actions release];
	_actions = nil;
	_actions = [[NSMutableArray alloc] init];
}

- (void) finishTeardown {
	//hide views
	if(_touchView) {
		[_touchView setDelegate:nil];
		[_touchView release];
	}
	_touchView = NULL;
	_webview = NULL;
	_deviceEventsTarget = NULL;
	_view = NULL;
}

- (void) render {
	//check for a container view
	if(!_view) {
		SMAdIPrivate * ad = (SMAdIPrivate *)_ad;
		[ad failWithError:_SMAdErrorInvalidView];
		return;
	}
	
	//check if a swipe should trigger new ad
	if([_model swipeForAdRequest]) {
		[_touchView setSwipeLeft:true];
		[_touchView setSwipeRight:true];
		[_touchView setSendEndIfSwiped:false];
	}
	
	//vars
	_keyWindow = [[self getKeyWindow] retain];
	_webview = [_inspector webview];
	
	//udpate invite webview
	NSObject * scroll = [[_webview subviews] lastObject];
	if([scroll respondsToSelector:@selector(setScrollEnabled:)]) {
		[(UIScrollView *)scroll setScrollEnabled:NO];
	}
	
	[_webview setDelegate:self];
	[_webview setOpaque:NO];
	[_webview setBackgroundColor:[UIColor clearColor]];
	
	//update takeover
	[_takeover loadHTMLString:[_inspector adcontent] baseURL:[NSURL URLWithString:[_loader adpath]]];
	
	//potentially update scroller to disabled.
	scroll = [[_takeover subviews] lastObject];
	if([scroll respondsToSelector:@selector(setScrollEnabled:)]) {
		[(UIScrollView *)scroll setScrollEnabled:NO];
	}
	
	[_takeover setDelegate:self];
	[_takeover setOpaque:NO];
	[_takeover setBackgroundColor:[UIColor clearColor]];
	
	//update frames
	[self updateFramesForInvite];
	
	//beacons
	[self prepareBeacons];
	[_initBeacon sendInit];
	[_amrBeacon sendAdModelReceived];
	[_echoBeacon sendEcho];
	[_inspector sendBannerShownBeacon];
	
	//attach view
	[_webview addSubview:_touchView];
	[_view addSubview:_webview];
	
	//send shown delegate and notification
	if(_adDelegate && [_adDelegate respondsToSelector:@selector(smAdBannerShown:)]) {
		[_adDelegate smAdBannerShown:_ad];
	}
}

- (void) hideToolbar {
	[_toolbar removeFromSuperview];
}

- (void) showToolbar {
	[_container addSubview:_toolbar];
}

- (void) showTakeover {
	//vars
	isInTakeover = true;
	if(_keyWindow) [_keyWindow release];
	_keyWindow = [[self getKeyWindow] retain];
	UIApplication * app = [UIApplication sharedApplication];
	didHaveStatusbar = ![app isStatusBarHidden];
	
	//pause auto updating if it's on
	[_ad pauseAutoUpdateBannerAds];
	
	//move webview to container and show takeover
	//[_touchView removeFromSuperview];
	
	[_webview removeFromSuperview];
	[_touchView removeFromSuperview];
	
	[_container addSubview:_takeover];
	[_container addSubview:_toolbar];
	[_takeover stringByEvaluatingJavaScriptFromString:@"showTakeover()"];
	[self updateFramesForTakeover];
	
	//for some reason the HTML creative takes a while to show the takeover.
	//this timeout is here so that when the creative is shown it isn't blank.
	[NSTimer scheduledTimerWithTimeInterval:.1 target:self
								   selector:@selector(finallyShowTakeover) userInfo:nil repeats:false];
}

- (void) finallyShowTakeover {
	SMAdIPrivate * pad = (SMAdIPrivate *)_ad;
	
	//setup frames for animation
	CGRect sc = [[UIScreen mainScreen] bounds];
	CGRect cf = [_container frame];
	CGRect cf2 = [_container frame];
	cf.origin.y = sc.size.height;
	[_container setFrame:cf];
	
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
	
	//the the delegate the invite is shown.
	if(_adDelegate && [_adDelegate respondsToSelector:@selector(smAdBannerTakeoverShown:)]) {
		[_adDelegate smAdBannerTakeoverShown:_ad];
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
	
	if(animated) {
		//animate it out
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
	
	//reset the y coordinate
	CGRect cf = [_container frame];
	cf.origin.y = 0;
	[_container setFrame:cf];
	
	//reset webview
	[self updateFramesForInvite];
	[_view addSubview:_webview];
	[_webview addSubview:_touchView];
	[_webview stringByEvaluatingJavaScriptFromString:@"show('inviteMain','takeoverMain')"];
	
	//tell the delegate the invite is hidden
	if(_adDelegate && [_adDelegate respondsToSelector:@selector(smAdBannerTakeoverHidden:)]) {
		[_adDelegate smAdBannerTakeoverHidden:_ad];
	}
	
	isInTakeover = false;
}

- (void) actionDidCloseTakeover:(SMAdActionBase <SMAdAction>*) action {
	[self closeTakeoverAnimated:false];
}

- (void) actionWantsToCloseTakeover:(SMAdActionBase <SMAdAction>*) action {
	[self closeTakeoverAnimated:false];
}

- (void) actionCantContinue:(SMAdActionBase <SMAdAction>*) action reason:(_SMAdError) reason {
	UIAlertView * alert = [[UIAlertView alloc] init];
	[alert addButtonWithTitle:@"OK"];
	if(reason == _SMAdErrorCantSendMail) {
		[alert setMessage:@"Please setup your email client to send email."];
	}
	[alert autorelease];
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
view:(SMAdTouchView *) view didSwipeLeft:(NSSet *)touches
event:(UIEvent *)event {
	[_ad requestBanner];
}

- (void)
view:(SMAdTouchView *) view didSwipeRight:(NSSet *)touches
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
	SMAdActionBase * action = [[SMActionHandler createActionWithRenderer:self
		webview:_webview request:req navType:navType] retain];
	if(!action) return TRUE;
	BOOL ret = [action returnForUIWebView];
	[action setViewController:_containervc];
	[action setModel:_model];
	if([action requiresPersistence]) [_actions addObject:action];
	[action execute];
	[action autorelease];
	return ret;
}

- (Boolean) isVisible {
	if([_container superview]) return true;
	if([_webview superview]) return true;
	return false;
}

- (Boolean) supportsOrientation:(UIDeviceOrientation) orientation {
	return true;
	if(UIDeviceOrientationIsPortrait(orientation)) return true;
	return false;
}

- (void) setOrientation:(UIDeviceOrientation) orientation updateFrames:(Boolean) update {
	_orientation = orientation;
	isportrait = UIDeviceOrientationIsPortrait(orientation);
	if(isInTakeover) return;
	if(update) [self updateFramesForInvite];
}

- (void) dealloc {
#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdBannerRendererV1");
#endif
	[_toolbar release];
	[_takeoverWindow release];
	[_keyWindow release];
	[_touchView release];
	[_container release];
	[_containervc release];
	[_takeover release];
	_takeover = nil;
	_containervc = nil;
	_container = nil;
	_webview = nil;
	_toolbar = nil;
	_takeoverWindow = nil;
	_keyWindow = nil;
	_webview = nil;
	_touchView = nil;
	_deviceEventsTarget = nil;
	_view = nil;
	[super dealloc];
}

@end
