
#import "SMAdRendererAdMeld.h"

@implementation SMAdRendererAdMeld

- (void) teardown {
	[_webview removeFromSuperview];
	_webview = NULL;
	_view = NULL;
}

- (void) updateFrames {
	if(isportrait) [_webview setFrame:CGRectMake(0,0,320,50)];
	else [_webview setFrame:CGRectMake(80,0,320,50)];
}

- (void) render {
	[self prepareBeacons];
	_engageBeacon = [[SMAdBeacon alloc] init];
	[_engageBeacon setDelegate:self];
	[_initBeacon sendInit];
	[_echoBeacon sendEcho];
	[_amrBeacon sendAdModelReceived];
	[_engageBeacon setModel:_model];
	_webview = [_inspector webview];
	//udpate invite webview
	NSObject * scroll = [[_webview subviews] lastObject];
	if([scroll respondsToSelector:@selector(setScrollEnabled:)]) {
		[(UIScrollView *)scroll setScrollEnabled:NO];
	}
	if([scroll respondsToSelector:@selector(setDelaysContentTouches:)]) {
		[(UIScrollView *)scroll setDelaysContentTouches:NO];
	}
	[_webview setDelegate:self];
	[self updateFrames];
	[_webview stringByEvaluatingJavaScriptFromString:@"document.body.style.marginLeft='0px';"];
	[_webview stringByEvaluatingJavaScriptFromString:@"document.body.style.marginTop='0px';"];
	[_webview stringByEvaluatingJavaScriptFromString:@"document.body.style.backgroundColor='transparent';"];
	[_webview setOpaque:NO];
	[_webview setBackgroundColor:[UIColor clearColor]];
	[_view addSubview:_webview];
}

- (void) setOrientation:(UIDeviceOrientation) orientation updateFrames:(Boolean) update {
	_orientation = orientation;
	isportrait = false;
	if(UIDeviceOrientationIsPortrait(orientation)) isportrait = true;
	[self updateFrames];
}

- (BOOL) supportsOrientation:(UIDeviceOrientation)orientation {
	return true;
}

- (Boolean) isVisible {
	if([_webview superview]) return true;
	return false;
}

- (BOOL)
webView:(UIWebView *) webView
shouldStartLoadWithRequest:(NSURLRequest *) request
navigationType:(UIWebViewNavigationType) navigationType
{
	[_engageBeacon sendEngagedWithContext:@"admeld"];
	[_echoBeacon sendEchoWithURLAsBURL:[[request URL] absoluteString]];
	[_closeBeacon sendClose];
	[self teardown];
	[[UIApplication sharedApplication] openURL:[request URL]];
	return NO;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdRendererAdMeld");
	#endif
	if(_engageBeacon) [_engageBeacon release];
	if(_webview) [_webview removeFromSuperview];
	_webview = NULL;
	_view = NULL;
	[super dealloc];
}

@end
