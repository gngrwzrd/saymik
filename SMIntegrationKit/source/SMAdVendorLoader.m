
NSString * adpfmt = @"http://amconf.videoegg.com/conf/iphone/current/%@/config.js";
NSString * adfmt  = @"http://adserver.adtechus.com/adrawdata/3.0/5108/%@/0/0/adct=text/html;AdId=%@;BnId=%@;misc=23242342;rid=$rid$;v=$v$";
#define SMAdVendorLoaderVersion 2

#import "SMAdVendorLoader.h"

@implementation SMAdVendorLoader
@synthesize bid = _bid;
@synthesize rid = _rid;
@synthesize area = _area;
@synthesize delegate = _delegate;
@synthesize adcontent = _adcontent;
@synthesize adurl = _adurl;

- (id) init {
	if(!(self = [super init])) return nil;
	_rid = [[self genRid] copy];
	_bid = [[[NSBundle mainBundle] bundleIdentifier] copy];
	_pui = [[[UIDevice currentDevice] uniqueIdentifier] copy];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	Boolean isphone = !(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
	Boolean isphone = true;
#endif

	if(isphone) _dim = @"iphone_standard";
	else _dim = @"ipad_standard";
	return self;
}

- (void) showPortraitBannerForWebView:(UIWebView *) webview {
	[webview stringByEvaluatingJavaScriptFromString:@"showInvitePortrait()"];
	[webview stringByEvaluatingJavaScriptFromString:@"portrait()"];
}

- (void) showLandscapeBannerForWebView:(UIWebView *) webview {
	[webview stringByEvaluatingJavaScriptFromString:@"showInviteLandscape()"];
	[webview stringByEvaluatingJavaScriptFromString:@"landscape()"];
}

- (void) showPortraitTakeoverForWebView:(UIWebView *) webview {
	[webview stringByEvaluatingJavaScriptFromString:@"showTakeoverPortrait()"];
	[webview stringByEvaluatingJavaScriptFromString:@"showTakeover()"];
}

- (void) showLandscapeTakeoverForWebView:(UIWebView *) webview {
	[webview stringByEvaluatingJavaScriptFromString:@"showTakeoverLandscape()"];
}

- (NSString *) urlencodeString:(NSString *) str {
	return [(NSString *) CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)str,NULL,
		(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
		kCFStringEncodingUTF8) autorelease];
}

- (NSString *) genRid {
	NSString * fmt = @"%lu%@";
	NSString * did = [UIDevice currentDevice].uniqueIdentifier;
	NSString * rid = [NSString stringWithFormat:fmt,time(NULL),did];
	return rid;
}

- (void) loadAdWithArea:(NSString *) area {
	[self setArea:area];
	_initEvent = [[NSDate date] retain];
	_adpurl = [[NSString stringWithFormat:adpfmt,area] copy];
	NSURL * _url = [NSURL URLWithString:_adpurl];
	NSURLRequest * _req = [NSURLRequest requestWithURL:_url];
	if(_adpdata) [_adpdata release];
	if(_addata) [_addata release];
	_adpdata = [[NSMutableData alloc] init];
	_addata = [[NSMutableData alloc] init];
	_adpconn = [[NSURLConnection alloc] initWithRequest:_req delegate:self startImmediately:true];
}

- (void) parseADPResponse {
	SBJsonParser * json = [[SBJsonParser alloc] init];
	NSDictionary * dic = [json objectWithData:_adpdata];
	NSString * url = [dic objectForKey:@"url"];
	NSString * dim = NULL;
	NSString * lang = NULL;
	NSString * intgid = NULL;
	NSTimeInterval ie = [_initEvent timeIntervalSince1970] * 1000;
	NSString * initEventString = [NSString stringWithFormat:@"%.0f",ie];
	NSString * vers = [NSString stringWithFormat:@"%.1f",(float)SMAdVendorLoaderVersion];
	
	//replace tokens
	url = [url stringByReplacingOccurrencesOfString:@"$v$" withString:vers];
	url = [url stringByReplacingOccurrencesOfString:@"$rid$" withString:_rid];
	
	//try and find lang code from adp response
	regex_t reg;
	char buf[8];
	char * regstr = "&?kvlang=([a-zA-Z]{2,2})";
	const char * urlcstring = [url UTF8String];
	regcomp(&reg,regstr,REG_EXTENDED);
	regmatch_t match;
	regmatch_t matches[2];
	if(regexec(&reg,urlcstring,2,matches,0) == 0) {
		match = matches[1];
		memcpy(buf,(char *)&urlcstring[match.rm_so],match.rm_eo-match.rm_so);
		lang = [NSString stringWithUTF8String:buf];
	}
	regfree(&reg);
	
	//try to find dim from adp response
	regstr = "&?kvdim=([a-zA-Z])";
	regcomp(&reg,regstr,REG_EXTENDED);
	if(regexec(&reg,urlcstring,2,matches,0) == 0) {
		match = matches[1];
		memcpy(buf,(char *)&urlcstring[match.rm_so],match.rm_eo-match.rm_so);
		dim = [NSString stringWithUTF8String:buf];
	}
	regfree(&reg);
	
	//try to find intgid from adp response
	regstr = "&?intgid=([a-zA-Z0-9-_])";
	regcomp(&reg,regstr,REG_EXTENDED);
	if(regexec(&reg,urlcstring,2,matches,0) == 0) {
		match = matches[1];
		memcpy(buf,(char *)&urlcstring[match.rm_so],match.rm_eo-match.rm_so);
		intgid = [NSString stringWithUTF8String:buf];
	}
	regfree(&reg);
	
	if(!intgid) {
		//try to find kvintgid from adp response
		regstr = "&?kvintgid=([a-zA-Z0-9-_])";
		regcomp(&reg,regstr,REG_EXTENDED);
		if(regexec(&reg,urlcstring,2,matches,0) == 0) {
			match = matches[1];
			memcpy(buf,(char *)&urlcstring[match.rm_so],match.rm_eo-match.rm_so);
			intgid = [NSString stringWithUTF8String:buf];
		}
		regfree(&reg);
	}
	
	//append parameters
	if([url rangeOfString:@"rid="].location == NSNotFound) url = [url stringByAppendingFormat:@";rid=%@",_rid];
	if([url rangeOfString:@"v="].location == NSNotFound) url = [url stringByAppendingFormat:@";v=%@",vers];
	if([url rangeOfString:@"version="].location == NSNotFound) url = [url stringByAppendingFormat:@";version=%@",vers];
	if([url rangeOfString:@"init="].location == NSNotFound) url = [url stringByAppendingFormat:@";init=%@",initEventString];
	if(_area && [url rangeOfString:@"area="].location == NSNotFound) url = [url stringByAppendingFormat:@";area=%@",_area];
	if(dim && [url rangeOfString:@"dim="].location == NSNotFound) url = [url stringByAppendingFormat:@";dim=%@",dim];
	if(lang && [url rangeOfString:@"lang="].location == NSNotFound) url = [url stringByAppendingFormat:@";lang=%@",lang];
	if(_bid && [url rangeOfString:@"bid="].location == NSNotFound) url = [url stringByAppendingFormat:@";bid=%@",_bid];
	if(intgid && [url rangeOfString:@"intgid="].location == NSNotFound) url = [url stringByAppendingFormat:@";intgid=%@",intgid];
	_adurl = [url copy];
	[json release];
	[self loadAd];
}

- (void) loadAd {
	_amrStartEvent = [[NSDate date] retain];
	NSURL * _url = [NSURL URLWithString:_adurl];
	NSURLRequest * _req = [NSURLRequest requestWithURL:_url];
	_adconn	= [[NSURLConnection alloc] initWithRequest:_req delegate:self startImmediately:true];
}

- (void) finish {
	_amrEvent = [[NSDate date] retain];
	_adcontent = [[NSString alloc] initWithBytes:[_addata bytes]
		length:[_addata length] encoding: NSUTF8StringEncoding];
	[self fireBeacons];
	if(_delegate && [_delegate respondsToSelector:@selector(smAdVendorLoaderDidFinish:)]) {
		[_delegate smAdVendorLoaderDidFinish:self];
	}
}

- (Boolean) isHouseAd {
	if(!_adcontent) return TRUE;
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

- (void) fireBeacons {
	NSLog(@"fire beacons!");
	
	//vars
	NSTimeInterval ie = [_initEvent timeIntervalSince1970] * 1000;
	NSDate * now = [NSDate date];
	NSTimeInterval nowi = [now timeIntervalSince1970] * 1000;
	NSString * curtime = [NSString stringWithFormat:@"%.0f",nowi];
	NSString * initEventString = [NSString stringWithFormat:@"%.0f",ie];
	NSString * beaconURL = @"http://beacon.videoegg.com/%@?";
	NSString * vers = [NSString stringWithFormat:@"%.1f",(float)SMAdVendorLoaderVersion];
	NSString * curtz = [NSString stringWithFormat:@"%d",([[NSTimeZone localTimeZone] secondsFromGMT]/60)*-1];
	NSURLConnection * conn = NULL;
	
	//times for vars
	float diff = ceil(([now timeIntervalSince1970]-[_initEvent timeIntervalSince1970]) * 1000);
	NSString * ets = [NSString stringWithFormat:@"%.0f",diff];
	NSTimeInterval start = [_amrStartEvent timeIntervalSince1970] * 1000;
	NSTimeInterval end = [_amrEvent timeIntervalSince1970] * 1000;
	diff = (end - start);
	NSString * artstring = [NSString stringWithFormat:@"%.0f",diff];
	
	//init
	NSString * initb = [NSString stringWithFormat:beaconURL,@"init"];
	initb = [initb stringByAppendingFormat:@"rid=%@",_rid];
	initb = [initb stringByAppendingFormat:@"&area=%@",_area];
	initb = [initb stringByAppendingFormat:@"&curtime=%@",initEventString];
	initb = [initb stringByAppendingFormat:@"&et=%@",@"0"];
	initb = [initb stringByAppendingFormat:@"&tech=%@",@"ios2"];
	initb = [initb stringByAppendingFormat:@"&v=%@",vers];
	initb = [initb stringByAppendingFormat:@"&curtz=%@",curtz];
	initb = [initb stringByAppendingFormat:@"&dim=%@",_dim];
	initb = [initb stringByAppendingFormat:@"&loc=%@",_bid];
	
	//ad model received
	NSString * amrb = [NSString stringWithFormat:beaconURL,@"admodelreceived"];
	amrb = [amrb stringByAppendingFormat:@"rid=%@",_rid];
	amrb = [amrb stringByAppendingFormat:@"&area=%@",_area];
	amrb = [amrb stringByAppendingFormat:@"&curtime=%@",curtime];
	amrb = [amrb stringByAppendingFormat:@"&et=%@",ets];
	amrb = [amrb stringByAppendingFormat:@"&tech=%@",@"ios2"];
	amrb = [amrb stringByAppendingFormat:@"&v=%@",vers];
	amrb = [amrb stringByAppendingFormat:@"&adserve=%@",@"adtech"];
	amrb = [amrb stringByAppendingFormat:@"&art=%@",artstring];
	if([self isHouseAd]) {
		amrb = [amrb stringByAppendingFormat:@"&adstat=%@",@"no"];
		amrb = [amrb stringByAppendingFormat:@"&reason=%@",@"DELIVERY"];
	} else {
		amrb = [amrb stringByAppendingFormat:@"&adstat=%@",@"ad"];
	}
	amrb = [amrb stringByAppendingFormat:@"&curtz=%@",curtz];
	amrb = [amrb stringByAppendingFormat:@"&dim=%@",_dim];
	amrb = [amrb stringByAppendingFormat:@"&loc=%@",_bid];
	amrb = [amrb stringByAppendingFormat:@"&pui=%@",_pui];
	
	//echo beacon
	NSString * echob = [NSString stringWithFormat:beaconURL,@"echo"];
	echob = [echob stringByAppendingFormat:@"rid=%@",_rid];
	echob = [echob stringByAppendingFormat:@"&area=%@",_area];
	echob = [echob stringByAppendingFormat:@"&curtime=%@",curtime];
	echob = [echob stringByAppendingFormat:@"&et=%@",ets];
	echob = [echob stringByAppendingFormat:@"&burl=%@",[self urlencodeString:_adurl]];
	
	//send init
	NSURLRequest * initr = [NSURLRequest requestWithURL:[NSURL URLWithString:initb]];
	conn = [NSURLConnection connectionWithRequest:initr delegate:nil];
	[conn start];
	
	//send amr
	NSURLRequest * amrr = [NSURLRequest requestWithURL:[NSURL URLWithString:amrb]];
	conn = [NSURLConnection connectionWithRequest:amrr delegate:nil];
	[conn start];
	
	//send echo
	NSURLRequest * echor = [NSURLRequest requestWithURL:[NSURL URLWithString:echob]];
	conn = [NSURLConnection connectionWithRequest:echor delegate:nil];
	[conn start];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *) err {
	error = true;
}

- (void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *)response {
	NSHTTPURLResponse * res = (NSHTTPURLResponse *) response;
	if([res statusCode] == 404) error = true;
}

- (void) connection:(NSURLConnection *) connection didReceiveData:(NSData *) data {
	if(connection == _adpconn) [_adpdata appendData:data];
	if(connection == _adconn) [_addata appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *) connection {
	if(error) {
		if(_delegate && [_delegate respondsToSelector:@selector(smAdVendorLoaderDidFail:)]) {
			[_delegate smAdVendorLoaderDidFail:self];
		}
		return;
	}
	if(connection == _adpconn) [self parseADPResponse];
	if(connection == _adconn) [self finish];
}

- (void) dealloc {
	[_initEvent release];
	[_amrStartEvent release];
	[_amrEvent release];
	[_pui release];
	[_rid release];
	[_bid release];
	[_dim release];
	[_area release];
	[_adpurl release];
	[_adpcontent release];
	[_adurl release];
	[_adcontent release];
	[_adpdata release];
	[_addata release];
	[_adpconn cancel];
	[_adpconn release];
	[_adconn cancel];
	[_adconn release];
	[super dealloc];
}

@end
