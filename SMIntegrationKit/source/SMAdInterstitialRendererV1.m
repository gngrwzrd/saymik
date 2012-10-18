
#import "SMAdInterstitialRendererV1.h"

@implementation SMAdInterstitialRendererV1

- (id) init {
	if(!(self = [super init])) return nil;
	UIScreen * ms = [UIScreen mainScreen];
	CGRect screen = [ms bounds];
	didHaveStatusbar = false;
	hasEngaged = false;
	_container = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
	_containervc = [[UIViewController alloc] init];
	_takeoverWindow = [[UIWindow alloc] initWithFrame:screen];
	[_containervc setView:_container];
	[self setupToolbar];
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

- (void) updateFrames {
	//update frames
	CGRect takeOverFrame = {0};
	CGRect toolbarFrame = {0};
	CGRect containerFrame = {0};
	toolbarFrame = CGRectMake(0,0,320,44);
	takeOverFrame = CGRectMake(0,44,320,480);
	containerFrame = CGRectMake(0,0,320,480);
	
	//set frames
	[_toolbar setFrame:toolbarFrame];
	[_takeover setFrame:takeOverFrame];
	[_container setFrame:containerFrame];
}

- (void) teardown {
	if(toredown) return;
	toredown = true;
	[_toolbar release];
	[_container release];
	[_takeoverWindow release];
	[_keyWindow release];
	_takeover = nil;
	_toolbar = nil;
	_takeoverWindow = nil;
	_container = nil;
	_keyWindow = nil;
}

- (void) render {	
	//vars
	UIApplication * app = [UIApplication sharedApplication];
	SMAdIPrivate * pad = (SMAdIPrivate *)_ad;
	_keyWindow = [[self getKeyWindow] retain];
	_takeover = [_inspector webview];
	didHaveStatusbar = ![app isStatusBarHidden];
	
	//pause auto updating if it's on
	//[_ad pauseAutoUpdateBannerAds];
	
	//update takeover
	NSObject * scroll = [[_takeover subviews] lastObject];
	if([scroll respondsToSelector:@selector(setScrollEnabled:)]) {
		[(UIScrollView *)scroll setScrollEnabled:NO];
	}
	[_takeover stringByEvaluatingJavaScriptFromString:@"showTakeover()"];
	[_takeover setDelegate:self];
	
	//update frames
	[self updateFrames];
	
	//set frame for animation
	CGRect cf = [_container frame];
	CGRect cf2 = [_container frame];
	cf.origin.y = [[UIScreen mainScreen] bounds].size.height;
	[_container setFrame:cf];
	
	//attach everything
	[_container addSubview:_takeover];
	[_container addSubview:_toolbar];
	[_takeoverWindow addSubview:_container];
	[_takeoverWindow makeKeyAndVisible];
	
	//beacons
	[self prepareBeacons];
	[_initBeacon sendInit];
	[_amrBeacon sendAdModelReceived];
	[_echoBeacon sendEcho];
	
	//animate in
	[UIView beginAnimations:@"showTakeover" context:nil];
	[UIView setAnimationDuration:[pad defaultAnimationDuration]];
	[UIView setAnimationDelegate:self];
	[_container setFrame:cf2];
	[UIView commitAnimations];
	
	//hide status bar if it's there
	if(didHaveStatusbar) {
		NSTimeInterval ti = [pad defaultAnimationDuration]-.02;
		[NSTimer scheduledTimerWithTimeInterval:ti target:self
			selector:@selector(hideStatusBar) userInfo:nil repeats:false];
	}
	
	//send shown delegate and notification
	if(_adDelegate && [_adDelegate respondsToSelector:@selector(smAdInterstitialShown:)]) {
		[_adDelegate smAdInterstitialShown:_ad];
	}
}

- (void) closeTakeover {
	//make sure we've got key window
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
	
	//beacons
	[_closeBeacon sendClose];
	
	//send hidden delegate and notification
	if(_adDelegate && [_adDelegate respondsToSelector:@selector(smAdInterstitialHidden:)]) {
		[_adDelegate smAdInterstitialHidden:_ad];
	}
	
	//restart auto updating ads if they're on
	//[_ad restartAutoUpdating];
}

- (void) hideModals {
	[self closeTakeover];
}

- (void) actionDidCloseTakeover:(SMAdActionBase <SMAdAction>*)action {
	[self closeTakeover];
}

- (void) actionWantsToCloseTakeover:(SMAdActionBase <SMAdAction>*)action {
	[self closeTakeover];
}

- (void) actionCantContinue:(SMAdActionBase <SMAdAction>*) action reason:(_SMAdError) reason {
	UIAlertView * alert = [[UIAlertView alloc] init];
	[alert addButtonWithTitle:@"OK"];
	switch(reason) {
		case _SMAdErrorCantSendMail:
			[alert setMessage:@"Please setup your email client to send email."];
			break;
	}
	[alert autorelease];
}

- (void) hideStatusBar {
	[[UIApplication sharedApplication] setStatusBarHidden:TRUE];
}

- (Boolean) isVisible {
	return !([_takeover superview] == NULL);
}

- (Boolean) supportsOrientation:(UIDeviceOrientation) orientation {
	if(UIDeviceOrientationIsLandscape(orientation)) return false;
	return true;
}

- (BOOL)
webView:(UIWebView *) webView shouldStartLoadWithRequest:(NSURLRequest *) req
navigationType:(UIWebViewNavigationType) navType
{
	if([[[req URL] absoluteString] isEqualToString:[[[_takeover request] URL] absoluteString]]) {
		return true;
	}
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
	NSLog(@"DEALLOC: SMAdInterstitialRendererV1");
	#endif
	[_toolbar release];
	[_container release];
	[_containervc release];
	[_takeoverWindow release];
	[_keyWindow release];
	_containervc = nil;
	_takeover = nil;
	_toolbar = nil;
	_takeoverWindow = nil;
	_container = nil;
	_keyWindow = nil;
	[super dealloc];
}

@end
