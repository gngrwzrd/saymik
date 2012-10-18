
#import "SMAdModel.h"
#import "defs.h"

@implementation SMAdModel
@synthesize swipeForAdRequest = _swipeForAdRequest;
@synthesize initEvent = _initEvent;
@synthesize adpStartEvent = _adpStartEvent;
@synthesize adpEndEvent = _adpEndEvent;
@synthesize adStartEvent = _adStartEvent;
@synthesize adEndEvent = _adEndEvent;
@synthesize isAdMeld = _isAdMeld;
@synthesize isSMIntegrationDisabled = _isSMIntegrationDisabled;
@synthesize bid = _bid;
@synthesize dim = _dim;
@synthesize rid = _rid;
@synthesize ccid = _ccid;
@synthesize burl = _burl;
@synthesize code = _code;
@synthesize area = _area;
@synthesize lang = _lang;
@synthesize pfam = _pfam;
@synthesize reason = _reason;
@synthesize intgid = _intgid;
@synthesize product = _product;
@synthesize deviceId = _deviceId;
@synthesize bannerArea = _bannerArea;
@synthesize interstitialArea = _interstitialArea;
@synthesize loadLocalFile = _loadLocalFile;
@synthesize loadRemoteURL = _loadRemoteURL;
@synthesize loadRemoteURLForInterstitial = _loadRemoteURLForInterstitial;
@synthesize loadRemoteURLForBanner = _loadRemoteURLForBanner;
@synthesize loadFCID = _loadFCID;
@synthesize loadPlacement = _loadPlacement;
@synthesize loadInterFCID = _loadInterFCID;

- (id) init {
	if(!(self = [super init])) return nil;
	_curtz = ([[NSTimeZone localTimeZone] secondsFromGMT]/60)*-1;
	return self;
}

- (void) recordInitTime {
	_initEvent = [[NSDate date] retain];
	//NSLog(@"recordInitTime: %f",[_initEvent timeIntervalSince1970]);
}

- (void) recordADPStart {
	_adpStartEvent = [[NSDate date] retain];
	//NSLog(@"recordADPStart: %f",[_adpStartEvent timeIntervalSince1970]);
}

- (void) recordADPEnd {
	_adpEndEvent = [[NSDate date] retain];
	//NSLog(@"recordADPEnd: %f",[_adpEndEvent timeIntervalSince1970]);
}

- (void) recordADStart {
	_adStartEvent = [[NSDate date] retain];
	//NSLog(@"recordADStart: %f",[_adStartEvent timeIntervalSince1970]);
}

- (void) recordADEnd {
	_adEndEvent = [[NSDate date] retain];
	//NSLog(@"recordADEnd: %f",[_adEndEvent timeIntervalSince1970]);
}

- (Boolean) isValidForType:(int) type {
	if(type == SMAdTypeBanner && !_loadLocalFile && !_loadRemoteURL && \
	   !_bannerArea && !_loadRemoteURLForBanner && !_loadFCID && !_loadPlacement) {
		return false;
	}
	if(type == SMAdTypeTwixt && !_loadLocalFile && !_loadRemoteURL && \
	   !_interstitialArea && !_loadRemoteURLForInterstitial && !_loadFCID && \
	   !_loadPlacement && !_loadInterFCID) {
		return false;
	}
	if(_loadPlacement && !_loadFCID) return false;
	return true;
}

- (NSString *) curtimezoneString {
	return [NSString stringWithFormat:@"%d",_curtz];
}

- (void) updateFromConfig:(NSMutableDictionary *) config {
	if([config objectForKey:@"bannerArea"]) _bannerArea = [[config objectForKey:@"bannerArea"] copy];
	if([config objectForKey:@"interstitialArea"]) _interstitialArea = [[config objectForKey:@"interstitialArea"] copy];
	if([config objectForKey:@"local"]) _loadLocalFile = [[config objectForKey:@"local"] copy];
	if([config objectForKey:@"remote"]) _loadRemoteURL = [[config objectForKey:@"remote"] copy];
	if([config objectForKey:@"swipeForAdRequest"]) _swipeForAdRequest = true;
	if([config objectForKey:@"remoteBanner"]) _loadRemoteURLForBanner = [[config objectForKey:@"remoteBanner"] copy];
	if([config objectForKey:@"remoteInterstitial"]) _loadRemoteURLForInterstitial = [[config objectForKey:@"remoteInterstitial"] copy];
	if([config objectForKey:@"fcid"]) _loadFCID = [[config objectForKey:@"fcid"] copy];
	if([config objectForKey:@"placement"]) _loadPlacement = [[config objectForKey:@"placement"] copy];
	if([config objectForKey:@"interfcid"]) _loadInterFCID = [[config objectForKey:@"interfcid"] copy];
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdModel");
	#endif
	[_initEvent release];
	[_adpStartEvent release];
	[_adpEndEvent release];
	[_adStartEvent release];
	[_adEndEvent release];
	[_burl release];
	[_bid release];
	[_dim release];
	[_rid release];
	[_ccid release];
	[_code release];
	[_area release];
	[_lang release];
	[_pfam release];
	[_reason release];
	[_intgid release];
	[_product release];
	[_deviceId release];
	[_bannerArea release];
	[_interstitialArea release];
	[_loadLocalFile release];
	[_loadRemoteURL release];
	[_loadRemoteURLForBanner release];
	[_loadRemoteURLForInterstitial release];
	[_loadPlacement release];
	[_loadFCID release];
	_initEvent = nil;
	[super dealloc];
}

@end
