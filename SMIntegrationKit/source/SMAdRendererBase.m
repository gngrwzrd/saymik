
#import "SMAdRendererBase.h"
#import "SMAdBeacon.h"

@implementation SMAdRendererBase
@synthesize ad = _ad;
@synthesize view = _view;
@synthesize loader = _loader;
@synthesize inspector = _inspector;
@synthesize adDelegate = _adDelegate;
@synthesize model = _model;

- (id) init {
	if(!(self = [super init])) return nil;
	_actions = [[NSMutableArray alloc] init];
	return self;
}

- (void) teardown {}
- (void) hideModals {}
- (void) appBackground {}
- (void) appForeground {}
- (Boolean) isVisible {
	return false;
}

- (UIWindow *) getKeyWindow {
	UIWindow * key = NULL;
	UIWindow * window = NULL;
	NSArray * windows = [UIApplication sharedApplication].windows;
	for(window in windows) {
		for(UIView * view in window.subviews) {
			BOOL alert = [view isKindOfClass:[UIAlertView class]];
			BOOL action = [view isKindOfClass:[UIActionSheet class]];
			if(alert || action) continue;
			else key = window;
        }
	}
	if(!key) key = [[UIApplication sharedApplication] keyWindow];
	return key;
}

- (void) prepareBeacons {
	//update model with any keys from the inspector
	[_model setCcid:[_inspector ccid]];
	[_model setCode:@"ad"];
	
	//create beacons
	_initBeacon = [[SMAdBeacon alloc] init];
	_amrBeacon = [[SMAdBeacon alloc] init];
	_echoBeacon = [[SMAdBeacon alloc] init];
	_closeBeacon = [[SMAdBeacon alloc] init];
	
	//setup delegates
	[_initBeacon setDelegate:self];
	[_amrBeacon setDelegate:self];
	[_echoBeacon setDelegate:self];
	[_closeBeacon setDelegate:self];
	
	//set models
	[_initBeacon setModel:_model];
	[_echoBeacon setModel:_model];
	[_amrBeacon setModel:_model];
	[_closeBeacon setModel:_model];
}

- (void) setOrientation:(UIDeviceOrientation) orientation updateFrames:(Boolean) update {
}

- (void) actionDidCloseTakeover:(SMAdActionBase <SMAdAction>*) action {
}

- (void) actionWantsToCloseTakeover:(SMAdActionBase <SMAdAction>*) action {
	
}

- (void) actionDidFinish:(SMAdActionBase *) action {
	if([action requiresPersistence]) [_actions removeObject:action];
}

- (void) beaconDidFail:(SMAdBeacon *) beacon {
	[beacon setDelegate:nil];
}

- (void) beaconDidFinish:(SMAdBeacon *) beacon {
	[beacon setDelegate:nil];
}

- (Boolean) supportsOrientation:(UIDeviceOrientation) orientation {
	return false;
}

- (Boolean) visible {
	return false;
}

- (Boolean) isInTakeover {
	return isInTakeover;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdRendererBase");
	#endif
	_ad = nil;
	[self setView:nil];
	[self setLoader:nil];
	[self setInspector:nil];
	[self setAdDelegate:nil];
	[_model release];
	[_actions release];
	[_initBeacon release];
	[_amrBeacon release];
	[_echoBeacon release];
	[_closeBeacon release];
	_deviceEventsTarget = nil;
	_initBeacon = nil;
	_amrBeacon = nil;
	_echoBeacon = nil;
	_closeBeacon = nil;
	_actions = nil;
	_model = nil;
	[super dealloc];
}

@end
