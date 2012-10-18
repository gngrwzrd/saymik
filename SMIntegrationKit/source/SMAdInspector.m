
#import "SMAdInspector.h"
#import "JSON.h"
#import "defs.h"
#import "targeting.h"

@implementation SMAdInspector
@synthesize adcontent = _adcontent;
@synthesize webview = _webview;
@synthesize delegate = _delegate;
@synthesize ccid = _ccid;
@synthesize reason = _reason;
@synthesize baseURL = _baseURL;

- (id) init {
	if(!(self = [super init])) return nil;
	_webview = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,1024,1024)];
	
	//setAllowsInlindeMediaPlayback, setMediaPlaybackRequiresUserAction
	//requires >= 4.0
	if([_webview respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
		[_webview setAllowsInlineMediaPlayback:TRUE];
		[_webview setMediaPlaybackRequiresUserAction:FALSE];
	}
	[_webview setDelegate:self];
	return self;
}

- (void) setAdcontent:(NSString *) adcontent {
	if(adcontent != _adcontent) {
		[_adcontent release];
		_adcontent = nil;
	}
	_adcontent = [adcontent copy];
}

- (void) load {
	NSURL * burl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	if(_baseURL) burl = _baseURL;
	[_webview loadHTMLString:_adcontent baseURL:burl];
}

- (void) webViewDidFinishLoad:(UIWebView *) webView {
	NSObject <SMAdInspectorDelegate> * _del = _delegate;
	if(_del && [_del respondsToSelector:@selector(adInspectorIsReady:)]) {
		[_del adInspectorIsReady:self];
	}
}

- (NSString *) getModelValueForKey:(NSString *) key {
	NSString * js = @"getModelValueForKey('%@')";
	NSString * jse = [NSString stringWithFormat:js,key];
	NSString * res = [_webview stringByEvaluatingJavaScriptFromString:jse];
	return res;
}

- (void) setModelValue:(NSString *) value forKey:(NSString *) key {
	NSString * js = @"setModelValueForKey('%@','%@')";
	NSString * jse = [NSString stringWithFormat:js,key,value];
	[_webview stringByEvaluatingJavaScriptFromString:jse];
}

- (void) setModelValue:(NSString *) value forKey:(NSString *) key forWebView:(UIWebView *) view {
	NSString * js = @"setModelValueForKey('%@','%@')";
	NSString * jse = [NSString stringWithFormat:js,key,value];
	[view stringByEvaluatingJavaScriptFromString:jse];
}

- (Boolean) canSendSessionBeacons {
	NSString * s = [self getModelValueForKey:@"canSendSessionBeacons"];
	return [s boolValue];
}

- (Boolean) canSendAppFocusBeacons {
	NSString * s = [self getModelValueForKey:@"canSendAppFocusBeacons"];
	return [s boolValue];
}

- (Boolean) isValid {
	//NSLog(@"isValid! %i %i",[_adcontent length],[_adcontent isEqualToString:@""]);
	return ![_adcontent isEqualToString:@""];
}

- (Boolean) isOldCreative {
	NSString * mabversion = [self MABVersion];
	NSRange range = [mabversion rangeOfString:@"."];
	return !(range.location == NSNotFound);
}

- (Boolean) is3RDParty {
	NSRange range = [_adcontent rangeOfString:@"tag.admeld"];
	if(range.location != NSNotFound) return true;
	return false;
}

- (Boolean) isAdMeld {
	NSRange range = [_adcontent rangeOfString:@"tag.admeld"];
	if(range.location != NSNotFound) return true;
	return false;
}

- (Boolean) deviceMismatch {
	Boolean isphone = ![SMAdUtility isPad];
	NSString * mabversion = [self MABVersion];
	NSRange range = [mabversion rangeOfString:@"."];
	if(!isphone && range.location != NSNotFound) return true;
	NSString * targetDevice = [self targetDevice];
	if([targetDevice isEqualToString:@"iphone"] && !isphone) return true;
	if([targetDevice isEqualToString:@"ipad"] && isphone) return true;
	return false;
}

- (Boolean) isNonMobileAd {
	NSRange range = [_adcontent rangeOfString:@"adFrames version="];
	if(range.location != NSNotFound) return TRUE;
	return FALSE;
}

- (Boolean) requiresTwoWebViews {
	NSString * inlineVideo = [self getModelValueForKey:@"requiresInlineVideo"];
	if([inlineVideo boolValue]) return true;
	return false;
}

- (NSString *) ccid {
	if(_ccid) return _ccid;
	NSString * ccid = NULL;
	regex_t reg;
	regmatch_t match;
	regmatch_t matches[2];
	char buf[32];
	size_t len = 0;
	char * regstr = "\"ccid\": ?\"([0-9-]{1,})\"";
	const char * accstr = [_adcontent UTF8String];
	if([self isHouseAd]) {
		regcomp(&reg,regstr,REG_EXTENDED);
		if(regexec(&reg,accstr,2,matches,0) == 0) {
			match = matches[1];
			len = match.rm_eo - match.rm_so;
			memcpy(buf,(char*)&accstr[match.rm_so],len);
			buf[len] = '\0';
			_ccid = [[NSString stringWithUTF8String:buf] copy];
			regfree(&reg);
			return _ccid;
		}
		regfree(&reg);
	}
	ccid = [_webview stringByEvaluatingJavaScriptFromString:@"getCCID()"];
	if(!ccid || [ccid isEqualToString:@""]) ccid = [self getModelValueForKey:@"ccid"];
	if(ccid && [ccid isEqualToString:@"%%CCID%%"]) ccid = NULL;
	if(ccid) _ccid = [ccid copy];
	return _ccid;
}

- (NSString *) reason {
	if(_reason) return _reason;
	if(![self isHouseAd]) return NULL;
	regex_t reg;
	regmatch_t match;
	regmatch_t matches[2];
	size_t len = 0;
	char buf[64];
	char * regstr = "\"reason\": ?\"([A-Za-z0-9 ]{1,})\"";
	const char * accstr = [_adcontent UTF8String];
	regcomp(&reg,regstr,REG_EXTENDED);
	if(regexec(&reg,accstr,2,matches,0) == 0) {
		match = matches[1];
		len = match.rm_eo - match.rm_so;
		memcpy(buf,(char*)&accstr[match.rm_so],len);
		buf[len] = '\0';
		_reason = [[NSString stringWithUTF8String:buf] copy];
	}
	regfree(&reg);
	return _reason;
}

- (NSString *) tpb {
	NSString * o = [self getModelValueForKey:@"tpb"];
	if(!o || [o isEqualToString:@""]) return NULL;
	return o;
}

- (Boolean) disableInviteTouchView {
	NSString * o = [self getModelValueForKey:@"disableInviteTouchView"];
	if(!o || [o isEqualToString:@""] || [o isEqualToString:@"false"]) return false;
	return true;
}

- (NSString *) MABVersion {
	NSString * mab = [_webview stringByEvaluatingJavaScriptFromString:@"mabVersion()"];
	if(!mab || [mab isEqualToString:@""]) mab = [self getModelValueForKey:@"mabVersion"];
	return mab;
}

- (NSString *) inviteOrientation {
	NSString * o = [self getModelValueForKey:@"inviteOrientation"];
	if(!o || [o isEqualToString:@""]) return NULL;
	return o;
}

- (NSString *) interstitialOrientation {
	NSString * o = [self getModelValueForKey:@"interstitialOrientation"];
	if(!o || [o isEqualToString:@""]) return NULL;
	return o;
}

- (NSString *) takeoverOrientation {
	NSString * o = [self getModelValueForKey:@"takeoverOrientation"];
	if(!o || [o isEqualToString:@""]) return NULL;
	return o;
}

- (Boolean) inviteOrientationPortrait {
	NSString * io = [self inviteOrientation];
	if([io isEqualToString:@"portrait"] ||
	[io isEqualToString:@"portrait_landscape"] ||
	[io isEqualToString:@"both"] ||
	[io isEqualToString:@"landscape_portrait"])
	{
		return true;
	}
	return false;
}

- (Boolean) inviteOrientationLandscape {
	NSString * io = [self inviteOrientation];
	if([io isEqualToString:@"landscape"] ||
	[io isEqualToString:@"portrait_landscape"] ||
	[io isEqualToString:@"both"] ||
	[io isEqualToString:@"landscape_portrait"])
	{
		return true;
	}
	return false;
}

- (Boolean) takeoverOrientationPortrait {
	NSString * io = [self takeoverOrientation];
	if([io isEqualToString:@"portrait"] ||
	[io isEqualToString:@"portrait_landscape"] ||
	[io isEqualToString:@"both"] ||
	[io isEqualToString:@"landscape_portrait"])
	{
		return true;
	}
	return false;
}

- (Boolean) takeoverOrientationLandscape {
	NSString * io = [self takeoverOrientation];
	if([io isEqualToString:@"landscape"] ||
	[io isEqualToString:@"portrait_landscape"] ||
	[io isEqualToString:@"both"] ||
	[io isEqualToString:@"landscape_portrait"])
	{
		return true;
	}
	return false;
}

- (Boolean) interstitialPortrait {
	NSString * io = [self interstitialOrientation];
	if([io isEqualToString:@"portrait"] ||
	[io isEqualToString:@"portrait_landscape"] ||
	[io isEqualToString:@"both"] ||
	[io isEqualToString:@"landscape_portrait"])
	{
		return true;
	}
	return false;
}

- (Boolean) interstitialLandscape {
	NSString * io = [self interstitialOrientation];
	if([io isEqualToString:@"landscape"] ||
	[io isEqualToString:@"portrait_landscape"] ||
	[io isEqualToString:@"both"] ||
	[io isEqualToString:@"landscape_portrait"])
	{
		return true;
	}
	return false;
}

- (Boolean) artworkIsLandscape {
	NSString * o = [self getModelValueForKey:@"artworkIsLandscape"];
	return [o boolValue];
}

- (NSString *) accelerometerFunctionName {
	NSString * df = [self getModelValueForKey:@"accelerometerFunctionName"];
	if(!df || [df isEqualToString:@""]) return NULL;
	return df;
}

- (NSString *) shakeFunctionName {
	NSString * df = [self getModelValueForKey:@"shakeFunctionName"];
	if(!df || [df isEqualToString:@""]) return NULL;
	return df;
}

- (NSString *) deviceFamily {
	NSString * df = [self getModelValueForKey:@"deviceFamily"];
	if(!df || [df isEqualToString:@""]) return NULL;
	return df;
}

- (NSString *) adType {
	NSString * df = [self getModelValueForKey:@"adtype"];
	if(!df || [df isEqualToString:@""]) return NULL;
	return df;
}

- (Boolean) isDeviceFamilyIOS {
	NSString * df = [self deviceFamily];
	return [df isEqualToString:@"ios"];
}

- (NSString *) renderVersion {
	return [self getModelValueForKey:@"renderVersion"];
}

- (NSString *) targetDevice {
	return [self getModelValueForKey:@"device"];
}

- (NSString *) bannerCTAURL {
	if(_bcta) return _bcta;
	NSString * u = [_webview stringByEvaluatingJavaScriptFromString:@"bannerCTAURL()"];
	if(!u || [u isEqualToString:@""]) u = [self getModelValueForKey:@"bannerCTAURL"];
	if(u && ![u isEqualToString:@""]) _bcta = [u copy];
	return _bcta;
}

- (Boolean) isHouseAd {
	if(!_adcontent) return FALSE;
	const char * accstr = [_adcontent UTF8String];
	char * regstr = "\"housead\": ?\"true\"";
	regex_t reg;
	regcomp(&reg,regstr,REG_EXTENDED);
	if(regexec(&reg,accstr,0,NULL,0) == 0) {
		regfree(&reg);
		return TRUE;
	}
	regfree(&reg);
	return FALSE;
}

- (Boolean) requiresNetworkStatus {
	NSString * res = [self getModelValueForKey:@"requiresNetworkStatus"];
	return [res boolValue];
}

- (Boolean) requiresOrientationEvents {
	NSString * res = [self getModelValueForKey:@"requiresOrientationEvents"];
	return [res boolValue];
}

- (Boolean) requiresAccelerometerEvents {
	NSString * res = [self getModelValueForKey:@"requiresAccelerometerEvents"];
	return [res boolValue];
}

- (Boolean) requiresShakeEvents {
	NSString * res = [self getModelValueForKey:@"requiresShakeEvents"];
	return [res boolValue];
}

- (void) portrait {
	[_webview stringByEvaluatingJavaScriptFromString:@"setOrientation(0)"];
	[_webview stringByEvaluatingJavaScriptFromString:@"portrait()"];
}

- (void) landscape {
	[_webview stringByEvaluatingJavaScriptFromString:@"setOrientation(1)"];
	[_webview stringByEvaluatingJavaScriptFromString:@"landscape()"];
}

- (void) sendBannerShownBeacon {
	[_webview stringByEvaluatingJavaScriptFromString:@"sendLoadBeacons()"];
	[_webview stringByEvaluatingJavaScriptFromString:@"processActionForId('bannershown')"];
}

- (void) sendCloseBeaconForUIWebView:(UIWebView *) view {
	[view stringByEvaluatingJavaScriptFromString:@"sendTSpentBeacons()"];
	[view stringByEvaluatingJavaScriptFromString:@"processActionForId('closed')"];
}

- (void) sendCloseBeacon {
	[_webview stringByEvaluatingJavaScriptFromString:@"sendTSpentBeacons()"];
	[_webview stringByEvaluatingJavaScriptFromString:@"processActionForId('closed')"];
}

- (void) sendEngagedBeacon {
	[_webview stringByEvaluatingJavaScriptFromString:@"sendTapBeacons()"];
	[_webview stringByEvaluatingJavaScriptFromString:@"processActionForId('engage')"];
}

- (void) sendScreenShownBeaconForUIWebView:(UIWebView *) view {
	[view stringByEvaluatingJavaScriptFromString:@"sendScreenShown()"];
	[view stringByEvaluatingJavaScriptFromString:@"processActionForId('screenshown')"];
}

- (void) sendScreenShownBeaconWithCurtime:(NSTimeInterval) curtime {
	NSString * ctime = [NSString stringWithFormat:@"%.0f",curtime];
	[self setModelValue:ctime forKey:@"screenshownCurtime"];
	[_webview stringByEvaluatingJavaScriptFromString:@"sendScreenShown()"];
	[_webview stringByEvaluatingJavaScriptFromString:@"processActionForId('screenshownCustomCurtime')"];
}

- (void) sendScreenShownBeacon {
	[_webview stringByEvaluatingJavaScriptFromString:@"sendScreenShown()"];
	[_webview stringByEvaluatingJavaScriptFromString:@"processActionForId('screenshown')"];
}

- (void) sendScreenHiddenBeaconWithCurtime:(NSTimeInterval) curtime {
	NSString * ctime = [NSString stringWithFormat:@"%.0f",curtime];
	[self setModelValue:ctime forKey:@"screenhiddenCurtime"];
	[_webview stringByEvaluatingJavaScriptFromString:@"sendScreenHidden()"];
	[_webview stringByEvaluatingJavaScriptFromString:@"processActionForId('screenhiddenCustomCurtime')"];
}

- (void) sendScreenHiddenBeacon {
	[_webview stringByEvaluatingJavaScriptFromString:@"sendScreenHidden()"];
	[_webview stringByEvaluatingJavaScriptFromString:@"processActionForId('screenhidden')"];
}

- (void) sendScreenHiddenBeaconForUIWebView:(UIWebView *) view {
	[view stringByEvaluatingJavaScriptFromString:@"sendScreenHidden()"];
	[view stringByEvaluatingJavaScriptFromString:@"processActionForId('screenhidden')"];
}

- (void) sendVideoStartWithCurtime:(NSString *) curtime andVidId:(NSString *) vidid {
	NSString * jse = [NSString stringWithFormat:@"fireVideoStartedBeacon('%@','%@');",vidid,curtime];
	[_webview stringByEvaluatingJavaScriptFromString:jse];
}

- (void) sendTimeInVideoWithCurtime:(NSString *) curtime vidId:(NSString *) vidid timeInVideo:(NSUInteger) tiv videoPercent:(NSUInteger) percent {
	NSString * js = @"fireTimeInVideoBeacon('%@','%i','%i','%@');";
	NSString * jse = [NSString stringWithFormat:js,vidid,tiv,percent,curtime];
	[_webview stringByEvaluatingJavaScriptFromString:jse];
}

- (void) adWasShown {
	[_webview stringByEvaluatingJavaScriptFromString:@"adWasShown()"];
}

- (void) adWasDestroyed {
	[_webview stringByEvaluatingJavaScriptFromString:@"adWasDestroyed()"];
}

- (void) adBecameActive {
	[_webview stringByEvaluatingJavaScriptFromString:@"adBecameActive()"];
}

- (void) adBecameInactive {
	[_webview stringByEvaluatingJavaScriptFromString:@"adBecameInactive()"];
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdInspector");
	#endif
	[self setWebview:nil];
	[self setAdcontent:nil];
	[self setDelegate:nil];
	[_ccid release];
	[_reason release];
	[_bcta release];
	[_baseURL release];
	_baseURL = NULL;
	_ccid = NULL;
	_reason = NULL;
	_bcta = NULL;
	[super dealloc];
}

@end
