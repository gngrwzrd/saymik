
#import "SMAdBeacon.h"

@implementation SMAdBeacon
@synthesize model = _model;
@synthesize delegate = _delegate;
@synthesize allowBeacons = _allowBeacons;
@synthesize fileurl = _fileurl;

- (id) init {
	if(!(self = [super init])) return nil;
	_first = true;
	_allowBeacons = true;
	attempts = 3;
	return self;
}

- (void) createBeacon:(NSString *) beacon {
	_beacon = [[NSString stringWithFormat:@"http://beacon.videoegg.com/%@?",beacon] retain];
}

- (void) addKey:(NSString *) key value:(NSString *) value {
	NSString * val = value;
	if(!val) return;
	if(!val) val = @"null";
	if([val isEqualToString:@""]) val = @"null";
	NSString * tmp = NULL;
	if(!_first) tmp = [_beacon stringByAppendingFormat:@"&%@=%@",key,val];
	if(_first) {
		tmp = [_beacon stringByAppendingFormat:@"%@=%@",key,val];
		_first = false;
	}
	[_beacon release];
	_beacon = [tmp retain];
}

- (void) sendInit {
	[self createBeacon:@"init"];
	
	//setup times
	NSTimeInterval it = [[_model initEvent] timeIntervalSince1970] * 1000;
	NSString * its = [NSString stringWithFormat:@"%.0f",it];
	
	//required params
	[self addKey:@"rid" value:[_model rid]];
	[self addKey:@"area" value:[_model area]];
	[self addKey:@"intgid" value:[_model intgid]];
	[self addKey:@"curtime" value:its];
	[self addKey:@"et" value:@"0"];
	
	//init specific
	[self addKey:@"tech" value:@"ios2"];
	[self addKey:@"v" value:[NSString stringWithFormat:@"%.1f",(float)SMAdBeaconVersion]];
	[self addKey:@"curtz" value:[_model curtimezoneString]];
	[self addKey:@"dim" value:[_model dim]];
	[self addKey:@"lang" value:[_model lang]];
	[self addKey:@"loc" value:[_model bid]]; //loc is app bundle id
	
	[self send];
}

- (void) sendEcho {
	[self createBeacon:@"echo"];
	
	//setup times
	NSDate * now = [NSDate date];
	NSTimeInterval nowi = [now timeIntervalSince1970] * 1000;
	float diff = ceil(([now timeIntervalSince1970]-[[_model initEvent] timeIntervalSince1970]) * 1000);
	NSString * curtime = [NSString stringWithFormat:@"%.0f",nowi];
	NSString * ets = [NSString stringWithFormat:@"%.0f",diff];
	
	//don't send if the time elapsed since init is greater than an hour.
	if(diff > 3600000) return;
	
	//required params
	[self addKey:@"rid" value:[_model rid]];
	[self addKey:@"area" value:[_model area]];
	[self addKey:@"intgid" value:[_model intgid]];
	[self addKey:@"curtime" value:curtime];
	[self addKey:@"et" value:ets];
	
	//specific to echo
	[self addKey:@"burl" value:[SMAdUtility urlencodeString:[_model burl]]];
	
	[self send];
}

- (void) sendEchoWithURLAsBURL:(NSString *) burl {
	[self createBeacon:@"echo"];
	
	//setup times
	NSDate * now = [NSDate date];
	NSTimeInterval nowi = [now timeIntervalSince1970] * 1000;
	float diff = ceil(([now timeIntervalSince1970]-[[_model initEvent] timeIntervalSince1970]) * 1000);
	NSString * curtime = [NSString stringWithFormat:@"%.0f",nowi];
	NSString * ets = [NSString stringWithFormat:@"%.0f",diff];
	
	//don't send if the time elapsed since init is greater than an hour.
	if(diff > 3600000) return;
	
	//required params
	[self addKey:@"rid" value:[_model rid]];
	[self addKey:@"area" value:[_model area]];
	[self addKey:@"intgid" value:[_model intgid]];
	[self addKey:@"curtime" value:curtime];
	[self addKey:@"et" value:ets];
	
	//specific to echo
	[self addKey:@"burl" value:[SMAdUtility urlencodeString:burl]];
	
	[self send];
}

- (void) sendAdModelReceived {
	[self createBeacon:@"admodelreceived"];
	
	//setup times
	NSDate * now = [NSDate date];
	NSTimeInterval nowi = [now timeIntervalSince1970] * 1000;
	NSString * curtime = [NSString stringWithFormat:@"%.0f",nowi];
	float diff = ceil(([now timeIntervalSince1970]-[[_model initEvent] timeIntervalSince1970]) * 1000);
	NSString * ets = [NSString stringWithFormat:@"%.0f",diff];
	
	//don't send if the time elapsed since init is greater than an hour.
	if(diff > 3600000) return;
	
	//setup art time
	NSTimeInterval start = [[_model adpStartEvent] timeIntervalSince1970] * 1000;
	NSTimeInterval end = [[_model adpEndEvent] timeIntervalSince1970] * 1000;
	diff = (end - start);
	NSString * artstring = [NSString stringWithFormat:@"%.0f",diff];
	
	//required params
	[self addKey:@"rid" value:[_model rid]];
	[self addKey:@"area" value:[_model area]];
	[self addKey:@"intgid" value:[_model intgid]];
	[self addKey:@"curtime" value:curtime];
	[self addKey:@"et" value:ets];
	
	//specific to ad model received
	NSString * prod = [_model product];
	if([_model isAdMeld]) prod = @"indirect";
	[self addKey:@"prod" value:prod];
	[self addKey:@"tech" value:@"ios2"];
	[self addKey:@"v" value:[NSString stringWithFormat:@"%.1f",(float)SMAdBeaconVersion]];
	NSString * adserv = @"adtech";
	if([_model isAdMeld]) adserv = @"admeld";
	[self addKey:@"adserv" value:adserv];
	[self addKey:@"art" value:artstring];
	[self addKey:@"atstat" value:[_model code]];
	if([[_model code] isEqualToString:@"no"]) [self addKey:@"reason" value:[_model reason]];
	if(![_model isAdMeld]) [self addKey:@"fcid" value:[_model ccid]];
	[self addKey:@"curtz" value:[_model curtimezoneString]];
	[self addKey:@"dim" value:[_model dim]];
	[self addKey:@"lang" value:[_model lang]];
	[self addKey:@"loc" value:[_model bid]];
	[self addKey:@"pui" value:[_model deviceId]];
	
	[self send];
}

- (void) sendClose {
	[self createBeacon:@"closed"];
	
	//setup times
	NSDate * now = [NSDate date];
	NSTimeInterval nowi = [now timeIntervalSince1970] * 1000;
	NSString * curtime = [NSString stringWithFormat:@"%.0f",nowi];
	float diff = ceil(([now timeIntervalSince1970]-[[_model initEvent] timeIntervalSince1970]) * 1000);
	NSString * ets = [NSString stringWithFormat:@"%.0f",diff];
	
	//don't send if the time elapsed since init is greater than an hour.
	if(diff > 3600000) return;
	
	//required params
	[self addKey:@"rid" value:[_model rid]];
	[self addKey:@"area" value:[_model area]];
	[self addKey:@"intgid" value:[_model intgid]];
	[self addKey:@"curtime" value:curtime];
	[self addKey:@"et" value:ets];
	
	//screen
	[self addKey:@"scr" value:@"0"];
	[self send];
}

- (void) sendEngagedWithContext:(NSString *) context {
	[self createBeacon:@"engaged"];
	
	//setup times
	NSDate * now = [NSDate date];
	NSTimeInterval nowi = [now timeIntervalSince1970] * 1000;
	NSString * curtime = [NSString stringWithFormat:@"%.0f",nowi];
	float diff = ceil(([now timeIntervalSince1970]-[[_model initEvent] timeIntervalSince1970]) * 1000);
	NSString * ets = [NSString stringWithFormat:@"%.0f",diff];
	
	//don't send if the time elapsed since init is greater than an hour.
	if(diff > 3600000) return;
	
	//required params
	[self addKey:@"rid" value:[_model rid]];
	[self addKey:@"area" value:[_model area]];
	[self addKey:@"intgid" value:[_model intgid]];
	[self addKey:@"curtime" value:curtime];
	[self addKey:@"et" value:ets];
	
	//screen
	NSString * ori = NULL;
	UIDeviceOrientation orient = [[UIDevice currentDevice] orientation];
	if(UIDeviceOrientationIsPortrait(orient)) ori = @"port";
	else ori = @"land";
	[self addKey:@"context" value:context];
	[self addKey:@"ornt" value:ori];
	[self send];
}

- (void) sendInvalidAdModel {
	[self createBeacon:@"admodelreceived"];
	
	//setup times
	NSDate * now = [NSDate date];
	NSTimeInterval nowi = [now timeIntervalSince1970] * 1000;
	NSString * curtime = [NSString stringWithFormat:@"%.0f",nowi];
	float diff = ceil(([now timeIntervalSince1970]-[[_model initEvent] timeIntervalSince1970]) * 1000);
	NSString * ets = [NSString stringWithFormat:@"%.0f",diff];
	
	//don't send if the time elapsed since init is greater than an hour.
	if(diff > 3600000) return;
	
	//setup art time
	NSTimeInterval start = [[_model adpStartEvent] timeIntervalSince1970] * 1000;
	NSTimeInterval end = [[_model adpEndEvent] timeIntervalSince1970] * 1000;
	diff = (end - start);
	NSString * artstring = [NSString stringWithFormat:@"%.0f",diff];
	
	//required params
	[self addKey:@"rid" value:[_model rid]];
	[self addKey:@"area" value:[_model area]];
	[self addKey:@"intgid" value:[_model intgid]];
	[self addKey:@"curtime" value:curtime];
	[self addKey:@"et" value:ets];
	
	//specific to ad model received
	NSString * prod = [_model product];
	if([_model isAdMeld]) prod = @"indirect";
	[self addKey:@"prod" value:prod];
	[self addKey:@"tech" value:@"ios2"];
	[self addKey:@"v" value:[NSString stringWithFormat:@"%.1f",(float)SMAdBeaconVersion]];
	NSString * adserv = @"adtech";
	if([_model isAdMeld]) adserv = @"admeld";
	[self addKey:@"adserv" value:adserv];
	[self addKey:@"art" value:artstring];
	[self addKey:@"atstat" value:@"nr"];
	if([[_model code] isEqualToString:@"no"]) [self addKey:@"reason" value:[_model reason]];
	if(![_model isAdMeld]) [self addKey:@"fcid" value:[_model ccid]];
	[self addKey:@"curtz" value:[_model curtimezoneString]];
	[self addKey:@"dim" value:[_model dim]];
	[self addKey:@"lang" value:[_model lang]];
	[self addKey:@"loc" value:[_model bid]];
	[self addKey:@"pui" value:[_model deviceId]];
	
	[self send];
}

- (void) sendDeviceMismatch {
	[self createBeacon:@"admodelreceived"];
	
	//setup times
	NSDate * now = [NSDate date];
	NSTimeInterval nowi = [now timeIntervalSince1970] * 1000;
	NSString * curtime = [NSString stringWithFormat:@"%.0f",nowi];
	float diff = ceil(([now timeIntervalSince1970]-[[_model initEvent] timeIntervalSince1970]) * 1000);
	NSString * ets = [NSString stringWithFormat:@"%.0f",diff];
	
	//don't send if the time elapsed since init is greater than an hour.
	if(diff > 3600000) return;
	
	//setup art time
	NSTimeInterval start = [[_model adpStartEvent] timeIntervalSince1970] * 1000;
	NSTimeInterval end = [[_model adpEndEvent] timeIntervalSince1970] * 1000;
	diff = (end - start);
	NSString * artstring = [NSString stringWithFormat:@"%.0f",diff];
	
	//required params
	[self addKey:@"rid" value:[_model rid]];
	[self addKey:@"area" value:[_model area]];
	[self addKey:@"intgid" value:[_model intgid]];
	[self addKey:@"curtime" value:curtime];
	[self addKey:@"et" value:ets];
	
	//specific to ad model received
	NSString * prod = [_model product];
	if([_model isAdMeld]) prod = @"indirect";
	[self addKey:@"prod" value:prod];
	[self addKey:@"tech" value:@"ios2"];
	[self addKey:@"v" value:[NSString stringWithFormat:@"%.1f",(float)SMAdBeaconVersion]];
	NSString * adserv = @"adtech";
	if([_model isAdMeld]) adserv = @"admeld";
	[self addKey:@"adserv" value:adserv];
	[self addKey:@"art" value:artstring];
	[self addKey:@"atstat" value:@"dm"];
	if([[_model code] isEqualToString:@"no"]) [self addKey:@"reason" value:[_model reason]];
	if(![_model isAdMeld]) [self addKey:@"fcid" value:[_model ccid]];
	[self addKey:@"curtz" value:[_model curtimezoneString]];
	[self addKey:@"dim" value:[_model dim]];
	[self addKey:@"lang" value:[_model lang]];
	[self addKey:@"loc" value:[_model bid]];
	[self addKey:@"pui" value:[_model deviceId]];
	
	[self send];
}

- (void) sendIntegrationMismatch {
	[self createBeacon:@"admodelreceived"];
	
	//setup times
	NSDate * now = [NSDate date];
	NSTimeInterval nowi = [now timeIntervalSince1970] * 1000;
	NSString * curtime = [NSString stringWithFormat:@"%.0f",nowi];
	float diff = ceil(([now timeIntervalSince1970]-[[_model initEvent] timeIntervalSince1970]) * 1000);
	NSString * ets = [NSString stringWithFormat:@"%.0f",diff];
	
	//don't send if the time elapsed since init is greater than an hour.
	if(diff > 3600000) return;
	
	//setup art time
	NSTimeInterval start = [[_model adpStartEvent] timeIntervalSince1970] * 1000;
	NSTimeInterval end = [[_model adpEndEvent] timeIntervalSince1970] * 1000;
	diff = (end - start);
	NSString * artstring = [NSString stringWithFormat:@"%.0f",diff];
	
	//required params
	[self addKey:@"rid" value:[_model rid]];
	[self addKey:@"area" value:[_model area]];
	[self addKey:@"intgid" value:[_model intgid]];
	[self addKey:@"curtime" value:curtime];
	[self addKey:@"et" value:ets];
	
	//specific to ad model received
	NSString * prod = [_model product];
	if([_model isAdMeld]) prod = @"indirect";
	[self addKey:@"prod" value:prod];
	[self addKey:@"tech" value:@"ios2"];
	[self addKey:@"v" value:[NSString stringWithFormat:@"%.1f",(float)SMAdBeaconVersion]];
	NSString * adserv = @"adtech";
	if([_model isAdMeld]) adserv = @"admeld";
	[self addKey:@"adserv" value:adserv];
	[self addKey:@"art" value:artstring];
	[self addKey:@"atstat" value:@"im"];
	if([[_model code] isEqualToString:@"no"]) [self addKey:@"reason" value:[_model reason]];
	if(![_model isAdMeld]) [self addKey:@"fcid" value:[_model ccid]];
	[self addKey:@"curtz" value:[_model curtimezoneString]];
	[self addKey:@"dim" value:[_model dim]];
	[self addKey:@"lang" value:[_model lang]];
	[self addKey:@"loc" value:[_model bid]];
	[self addKey:@"pui" value:[_model deviceId]];
	
	[self send];
}

- (void) sendNonMobile {
	[self createBeacon:@"admodelreceived"];
	
	//setup times
	NSDate * now = [NSDate date];
	NSTimeInterval nowi = [now timeIntervalSince1970] * 1000;
	NSString * curtime = [NSString stringWithFormat:@"%.0f",nowi];
	float diff = ceil(([now timeIntervalSince1970]-[[_model initEvent] timeIntervalSince1970]) * 1000);
	NSString * ets = [NSString stringWithFormat:@"%.0f",diff];
	
	//don't send if the time elapsed since init is greater than an hour.
	if(diff > 3600000) return;
	
	//setup art time
	NSTimeInterval start = [[_model adpStartEvent] timeIntervalSince1970] * 1000;
	NSTimeInterval end = [[_model adpEndEvent] timeIntervalSince1970] * 1000;
	diff = (end - start);
	NSString * artstring = [NSString stringWithFormat:@"%.0f",diff];
	
	//required params
	[self addKey:@"rid" value:[_model rid]];
	[self addKey:@"area" value:[_model area]];
	[self addKey:@"intgid" value:[_model intgid]];
	[self addKey:@"curtime" value:curtime];
	[self addKey:@"et" value:ets];
	
	//specific to ad model received
	NSString * prod = [_model product];
	if([_model isAdMeld]) prod = @"indirect";
	[self addKey:@"prod" value:prod];
	[self addKey:@"tech" value:@"ios2"];
	[self addKey:@"v" value:[NSString stringWithFormat:@"%.1f",(float)SMAdBeaconVersion]];
	NSString * adserv = @"adtech";
	if([_model isAdMeld]) adserv = @"admeld";
	[self addKey:@"adserv" value:adserv];
	[self addKey:@"art" value:artstring];
	[self addKey:@"atstat" value:@"tm"];
	if([[_model code] isEqualToString:@"no"]) [self addKey:@"reason" value:[_model reason]];
	if(![_model isAdMeld]) [self addKey:@"fcid" value:[_model ccid]];
	[self addKey:@"curtz" value:[_model curtimezoneString]];
	[self addKey:@"dim" value:[_model dim]];
	[self addKey:@"lang" value:[_model lang]];
	[self addKey:@"loc" value:[_model bid]];
	[self addKey:@"pui" value:[_model deviceId]];
	
	[self send];
}

- (void) sendAdModelTimeout {
	
}

- (void) send {
	if(bconn) {
		[bconn release];
		bconn = nil;
	}
	if(!_allowBeacons) return;
	NSURL * url = [NSURL URLWithString:_beacon];
	NSURLRequest * request = [NSURLRequest requestWithURL:url];
	bconn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:true];
}

- (void) connection:(NSURLConnection *) connection
didReceiveResponse:(NSURLResponse *) response
{
	return;
	NSHTTPURLResponse * res = (NSHTTPURLResponse *) response;
	if([res statusCode] != 200) _err = true;
	_delegate = nil;
}

- (void) connection:(NSURLConnection *) connection
didFailWithError:(NSError *) error
{
	return;
	if(attempts > 0) {
		attempts--;
		if(_delegate && [_delegate respondsToSelector:@selector(beaconDidFail:)]) {
			[_delegate beaconDidFail:self];
		}
	}
	_delegate = nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *) connection {
	return;
	if(_err) {
		if(attempts > 0) {
			attempts--;
			if(_delegate && [_delegate respondsToSelector:@selector(beaconDidFail:)]) {
				[_delegate beaconDidFail:self];
			}
		}
	} else {
		if(_delegate && [_delegate respondsToSelector:@selector(beaconDidFinish:)]) {
			[_delegate beaconDidFinish:self];
		}
	}
	_delegate = nil;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdBeacon");
	#endif
	[self setDelegate:nil];
	_delegate = nil;
	[bconn cancel];
	[bconn release];
	[_beacon release];
	[_fileurl release];
	[super dealloc];
}

@end
