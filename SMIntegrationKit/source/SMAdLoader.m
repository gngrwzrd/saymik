
#import "SMAdLoader.h"
#import "defs.h"
#import "JSON.h"

static NSString * adpurl_token = \
@"http://amconf.videoegg.com/conf/iphone/current/%@/config.js?bid=%@";

@implementation SMAdLoader
@synthesize model = _model;
@synthesize delegate = _delegate;
@synthesize adpcontent = _adpcontent;
@synthesize adpath = _adpath;
@synthesize adpurl = _adpurl;

- (void) appBackground {}

- (void) finished {
	if(_delegate && [_delegate \
	respondsToSelector:@selector(loaderDidComplete:)])
	{
		[_delegate loaderDidComplete:self];
	}
}

- (void) failWithError:(_SMAdError) error {
	if(_delegate && [_delegate respondsToSelector:@selector(loaderDidFail:error:)]) {
		[_delegate loaderDidFail:self error:error];
	}
}

- (void) fail {
	if(_delegate && [_delegate respondsToSelector:@selector(loaderDidFail:)]) {
		[_delegate loaderDidFail:self];
	}
}

- (void) loadADP {
	if(adpconn) {
		[adpconn cancel];
		[adpconn release];
	}
	if(adpdata) [adpdata release];
	NSString * area = [_model area];
	NSString * bid = [_model bid];
	NSString * url = [NSString stringWithFormat:adpurl_token,area,bid];
	NSURL * adpurl = [NSURL URLWithString:url];
	NSURLRequest * adpreq = [NSURLRequest requestWithURL:adpurl];
	adpdata = [[NSMutableData alloc] init];
	if(_delegate && [_delegate respondsToSelector:@selector(loaderDidStartADPRequest:)]) {
		[_delegate loaderDidStartADPRequest:self];
	}
	adpconn = [[NSURLConnection alloc] initWithRequest:adpreq delegate:self startImmediately:TRUE];
}

- (void) loadAD {
	if(adconn) {
		[adconn cancel];
		[adconn release];
	}
	if(addata) [addata release];
	_adpath = [_adpurl copy];
	addata = [[NSMutableData alloc] init];
	NSURL * adurl = [NSURL URLWithString:_adpurl];
	NSURLRequest * adreq = [NSURLRequest requestWithURL:adurl];
	if(_delegate && [_delegate respondsToSelector:@selector(loaderDidStartADRequest:)]) {
		[_delegate loaderDidStartADRequest:self];
	}
	adconn = [[NSURLConnection alloc] initWithRequest:adreq delegate:self startImmediately:TRUE];
}

- (void) load {
	[self loadADP];
}

- (void) loadFile:(NSString *) adfile {
	NSBundle * mb = [NSBundle mainBundle];
	NSString * rs = [mb resourcePath];
	NSFileManager * fm = [NSFileManager defaultManager];
	NSString * path = [rs stringByAppendingPathComponent:adfile];
	_adpath = [path copy];
	if(![fm fileExistsAtPath:path]) {
		[self failWithError:_SMAdErrorLocalFileNotFound];
		return;
	}
	addata = [[fm contentsAtPath:path] retain];
	[self finished];
}

- (void) loadAdWithFCID:(NSString *) fcid {
	[self loadAdWithFCID:fcid andPlacementId:nil];
}

- (void) loadAdWithFCID:(NSString *) fcid andPlacementId:(NSString *) placement {
	if([fcid rangeOfString:@"-"].location == NSNotFound) {
		[self failWithError:_SMAdErrorInvalidFCID];
		return;
	}
	NSArray * parts = [fcid componentsSeparatedByString:@"-"];
	NSString * a = [parts objectAtIndex:0];
	NSString * b = [parts objectAtIndex:1];
	NSString * adurl = NULL;
	if(fcid && placement) adurl = [NSString stringWithFormat:@"http://adserver.adtechus.com/adrawdata/3.0/5108.1/%@/0/0/adct=text/html;AdId=%@;BnId=%@;misc=23242342;rid=$rid$;v=$v$",placement,a,b];
	else adurl = [NSString stringWithFormat:@"http://adserver.adtechus.com/adrawdata/3.0/5108.1/1518897/0/0/adct=text/html;AdId=%@;BnId=%@;misc=23242342;rid=$rid$;v=$v$",a,b];
	if(adconn) {
		[adconn cancel];
		[adconn release];
	}
	if(addata) [addata release];
	addata = [[NSMutableData alloc] init];
	NSString * rid = [_model rid];
	NSString * area = [_model area];
	NSString * dim = [_model dim];
	NSString * lang = [_model lang];
	NSString * bid = [_model bid];
	NSString * vers = [NSString stringWithFormat:@"%.1f",(float)SMAdBeaconVersion];
	NSTimeInterval ie = [[_model initEvent] timeIntervalSince1970] * 1000;
	NSString * initEventString = [NSString stringWithFormat:@"%.0f",ie];
	NSString * tmp1 = [adurl stringByReplacingOccurrencesOfString:@"$v$" withString:vers];
	NSString * tmp2 = [tmp1 stringByReplacingOccurrencesOfString:@"$rid$" withString:rid];
	if(rid && [tmp2 rangeOfString:@"rid="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";rid=%@",rid];
	}
	if(rid && [tmp2 rangeOfString:@"kvrid="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";kvrid=%@",rid];
	}
	if(vers && [tmp2 rangeOfString:@"v="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";v=%@",vers];
	}
	if(vers && [tmp2 rangeOfString:@"version="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";version=%@",vers];
	}
	if(initEventString && [tmp2 rangeOfString:@"init="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";init=%@",initEventString];
	}
	if(area && [tmp2 rangeOfString:@"area="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";area=%@",area];
	}
	if(dim && [tmp2 rangeOfString:@"dim="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";dim=%@",dim];
	}
	if(dim && [tmp2 rangeOfString:@"kvdim="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";kvdim=%@",dim];
	}
	if(lang && [tmp2 rangeOfString:@"lang="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";lang=%@",lang];
	}
	if([tmp2 rangeOfString:@"kvtech="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingString:@";kvtech=ios2"];
	}
	if(bid && [tmp2 rangeOfString:@"bid="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";bid=%@",bid];
	}
	if([tmp2 rangeOfString:@"kvdid="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";kvdid=%@",[_model deviceId]];
	}
	NSURL * _adurl_ = [NSURL URLWithString:tmp2];
	NSURLRequest * adreq = [NSURLRequest requestWithURL:_adurl_];
	adconn = [[NSURLConnection alloc] initWithRequest:adreq delegate:self startImmediately:TRUE];
	_adpath	= [tmp2 copy];
}

- (void) loadAdURL:(NSString *) adurl {
	if(adconn) {
		[adconn cancel];
		[adconn release];
	}
	if(addata) [addata release];
	addata = [[NSMutableData alloc] init];
	NSString * rid = [_model rid];
	NSString * area = [_model area];
	NSString * dim = [_model dim];
	NSString * lang = [_model lang];
	NSString * bid = [_model bid];
	NSString * vers = [NSString stringWithFormat:@"%.1f",(float)SMAdBeaconVersion];
	NSTimeInterval ie = [[_model initEvent] timeIntervalSince1970] * 1000;
	NSString * initEventString = [NSString stringWithFormat:@"%.0f",ie];
	NSString * tmp1 = [adurl stringByReplacingOccurrencesOfString:@"$v$" withString:vers];
	NSString * tmp2 = [tmp1 stringByReplacingOccurrencesOfString:@"$rid$" withString:rid];
	Boolean needsq = true;
	if([adurl rangeOfString:@"?"].location != NSNotFound) needsq = false;
	if([tmp2 rangeOfString:@"rid="].location == NSNotFound) {
		if(needsq) {
			tmp2 = [tmp2 stringByAppendingFormat:@"?rid=%@",rid];
			needsq = false;
		} else tmp2 = [tmp2 stringByAppendingFormat:@"&rid=%@",rid];
	}
	if([tmp2 rangeOfString:@"kvrid="].location == NSNotFound) {
		if(needsq) {
			tmp2 = [tmp2 stringByAppendingFormat:@"?kvrid=%@",rid];
			needsq = false;
		} else tmp2 = [tmp2 stringByAppendingFormat:@"&kvrid=%@",rid];
	}
	if([tmp2 rangeOfString:@"v="].location == NSNotFound) {
		if(needsq) {
			tmp2 = [tmp2 stringByAppendingFormat:@"?v=%@",vers];
			needsq = false;
		} else tmp2 = [tmp2 stringByAppendingFormat:@"&v=%@",vers];
	}
	if([tmp2 rangeOfString:@"version="].location == NSNotFound) {
		if(needsq) {
			tmp2 = [tmp2 stringByAppendingFormat:@"?version=%@",vers];
			needsq = false;
		} else tmp2 = [tmp2 stringByAppendingFormat:@"&version=%@",vers];
	}
	if([tmp2 rangeOfString:@"init="].location == NSNotFound) {
		if(needsq) {
			tmp2 = [tmp2 stringByAppendingFormat:@"?init=%@",initEventString];
			needsq = false;
		} else tmp2 = [tmp2 stringByAppendingFormat:@"&init=%@",initEventString];
	}
	if(area && [tmp2 rangeOfString:@"area="].location == NSNotFound) {
		if(needsq) {
			tmp2 = [tmp2 stringByAppendingFormat:@"?area=%@",area];
			needsq = false;
		} else tmp2 = [tmp2 stringByAppendingFormat:@"&area=%@",area];
	}
	if(dim && [tmp2 rangeOfString:@"dim="].location == NSNotFound) {
		if(needsq) {
			needsq = false;
			tmp2 = [tmp2 stringByAppendingFormat:@"?dim=%@",dim];
		} else tmp2 = [tmp2 stringByAppendingFormat:@"&dim=%@",dim];
	}
	if(dim && [tmp2 rangeOfString:@"kvdim="].location == NSNotFound) {
		if(needsq) {
			needsq = false;
			tmp2 = [tmp2 stringByAppendingFormat:@"?kvdim=%@",dim];
		} else tmp2 = [tmp2 stringByAppendingFormat:@"&kvdim=%@",dim];
	}
	if(lang && [tmp2 rangeOfString:@"lang="].location == NSNotFound) {
		if(needsq) {
			tmp2 = [tmp2 stringByAppendingFormat:@"?lang=%@",lang];
			needsq = false;
		} else tmp2 = [tmp2 stringByAppendingFormat:@"&lang=%@",lang];
	}
	if([tmp2 rangeOfString:@"kvtech="].location == NSNotFound) {
		if(needsq) {
			tmp2 = [tmp2 stringByAppendingString:@"?kvtech=ios2"];
			needsq = false;
		} else tmp2 = [tmp2 stringByAppendingString:@"&kvtech=ios2"];
	}
	if(bid && [tmp2 rangeOfString:@"bid="].location == NSNotFound) {
		if(needsq) {
			tmp2 = [tmp2 stringByAppendingFormat:@"?bid=%@",bid];
			needsq = false;
		} else tmp2 = [tmp2 stringByAppendingFormat:@"&bid=%@",bid];
	}
	if([tmp2 rangeOfString:@"kvdid="].location == NSNotFound) {
		if(needsq) {
			tmp2 = [tmp2 stringByAppendingFormat:@"?kvdid=%@",[_model deviceId]];
			//needsq = false;
		} else tmp2 = [tmp2 stringByAppendingFormat:@"&kvdid=%@",[_model deviceId]];
	}
	NSURL * _adurl_ = [NSURL URLWithString:tmp2];
	NSURLRequest * adreq = [NSURLRequest requestWithURL:_adurl_];
	adconn = [[NSURLConnection alloc] initWithRequest:adreq delegate:self startImmediately:TRUE];
	_adpath	= [tmp2 copy];
}

- (void) parseADPResponse {
	if(err) {
		[self failWithError:_SMAdErrorNetworkError];
		return;
	}
	
	NSString * intgid = NULL;
	NSString * dim = NULL;
	NSString * lang = NULL;
	SBJsonParser * json = [[SBJsonParser alloc] init];
	if(_adpcontent) [_adpcontent release];
	_adpcontent = [[json objectWithData:adpdata] retain];
	NSString * tmpurl = [_adpcontent objectForKey:@"url"];
	
	//try and find lang code from adp response
	regex_t reg;
	char buf[8];
	char * regstr = "&?kvlang=([a-zA-Z]{2,2})";
	const char * urlcstring = [tmpurl UTF8String];
	regcomp(&reg,regstr,REG_EXTENDED);
	regmatch_t match;
	regmatch_t matches[2];
	if(regexec(&reg,urlcstring,2,matches,0) == 0) {
		match = matches[1];
		memcpy(buf,(char *)&urlcstring[match.rm_so],match.rm_eo-match.rm_so);
		lang = [NSString stringWithUTF8String:buf];
		[_model setLang:lang];
	}
	regfree(&reg);
	
	//try to find dim from adp response
	regstr = "&?kvdim=([a-zA-Z])";
	regcomp(&reg,regstr,REG_EXTENDED);
	if(regexec(&reg,urlcstring,2,matches,0) == 0) {
		match = matches[1];
		memcpy(buf,(char *)&urlcstring[match.rm_so],match.rm_eo-match.rm_so);
		dim = [NSString stringWithUTF8String:buf];
		[_model setDim:dim];
	}
	regfree(&reg);
	
	//try to find intgid from adp response
	regstr = "&?intgid=([a-zA-Z0-9-_])";
	regcomp(&reg,regstr,REG_EXTENDED);
	if(regexec(&reg,urlcstring,2,matches,0) == 0) {
		match = matches[1];
		memcpy(buf,(char *)&urlcstring[match.rm_so],match.rm_eo-match.rm_so);
		intgid = [NSString stringWithUTF8String:buf];
		[_model setIntgid:intgid];
	}
	regfree(&reg);
	
	//try to find kvintgid from adp response
	if(!intgid) {
		regstr = "&?kvintgid=([a-zA-Z0-9-_])";
		regcomp(&reg,regstr,REG_EXTENDED);
		if(regexec(&reg,urlcstring,2,matches,0) == 0) {
			match = matches[1];
			memcpy(buf,(char *)&urlcstring[match.rm_so],match.rm_eo-match.rm_so);
			intgid = [NSString stringWithUTF8String:buf];
		}
		regfree(&reg);
	}
	//assemble url
	dim = [_model dim];
	lang = [_model lang];
	NSString * rid = [_model rid];
	NSString * area = [_model area];
	NSString * bid = [_model bid];
	NSString * vers = [NSString stringWithFormat:@"%.1f",(float)SMAdBeaconVersion];
	NSTimeInterval ie = [[_model initEvent] timeIntervalSince1970] * 1000;
	NSString * initEventString = [NSString stringWithFormat:@"%.0f",ie];
	NSString * tmp1 = [tmpurl stringByReplacingOccurrencesOfString:@"$v$" withString:vers];
	NSString * tmp2 = [tmp1 stringByReplacingOccurrencesOfString:@"$rid$" withString:rid];
	if([tmp2 rangeOfString:@"rid="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";rid=%@",rid];
	}
	if([tmp2 rangeOfString:@"kvrid="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";kvrid=%@",rid];
	}
	if([tmp2 rangeOfString:@"v="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";v=%@",vers];
	}
	if([tmp2 rangeOfString:@"version="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";version=%@",vers];
	}
	if([tmp2 rangeOfString:@"init="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";init=%@",initEventString];
	}
	if(area && [tmp2 rangeOfString:@"area="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";area=%@",area];
	}
	if(dim && [tmp2 rangeOfString:@"dim="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";dim=%@",dim];
	}
	if(dim && [tmp2 rangeOfString:@"kvdim="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";kvdim=%@",dim];
	}
	if(lang && [tmp2 rangeOfString:@"lang="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";lang=%@",lang];
	}
	if(bid && [tmp2 rangeOfString:@"bid="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";bid=%@",bid];
	}
	if(intgid && [tmp2 rangeOfString:@"intgid="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";intgid=%@",intgid];
	}
	if([tmp2 rangeOfString:@"kvtech="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingString:@";kvtech=ios2"];
	}
	if([tmp2 rangeOfString:@"kvdid="].location == NSNotFound) {
		tmp2 = [tmp2 stringByAppendingFormat:@";kvdid=%@",[_model deviceId]];
	}
	_adpurl = [tmp2 copy];
	[json release];
}

- (void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *) response {
	NSHTTPURLResponse * res = (NSHTTPURLResponse *)response;
	if([res statusCode] != 200) {
		err = true;
	}
}

- (void) connection:(NSURLConnection *) connection didReceiveData:(NSData *) data {
	if(connection == adpconn) [adpdata appendData:data];
	if(connection == adconn) [addata appendData:data];
}

- (void) connection:(NSURLConnection *) connection didFailWithError:(NSError *) error {
	[self failWithError:_SMAdErrorNetworkError];
}

- (void) connectionDidFinishLoading:(NSURLConnection *) connection {
	if(connection == adpconn) {
		if(_delegate && [_delegate respondsToSelector:@selector(loaderDidFinishADPRequest:)]) {
			[_delegate loaderDidFinishADPRequest:self];
		}
		[self parseADPResponse];
		[self loadAD];
	} else {
		if(_delegate && [_delegate respondsToSelector:@selector(loaderDidFinishADRequest:)]) {
			[_delegate loaderDidFinishADRequest:self];
		}
		[self finished];
	}
}

- (void) cancel {
	if(adpconn) {
		[adpconn cancel];
		[adpconn release];
		adpconn = nil;
	}
	if(adconn) {
		[adconn cancel];
		[adconn release];
		adconn = nil;
	}
}

- (Boolean) isLoading {
	return FALSE;
}

- (NSString *) adcontent {
	NSString * content = NULL;
	NSStringEncoding enc = 0;
	if(addata) {
		enc = NSASCIIStringEncoding;
		content = [[NSString alloc] initWithData:addata encoding:enc];
		//content = [[NSString alloc] initWithBytes:[addata bytes] length:[addata length] encoding: NSUTF8StringEncoding];
	}
	return [content autorelease];
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdLoader");
	#endif
	[self setDelegate:nil];
	[adpconn cancel];
	[adconn cancel];
	[_adpcontent release];
	[_adpurl release];
	[_adpath release];
	[adpconn release];
	[adconn release];
	[addata release];
	[adpdata release];
	_model = nil;
	_adpath = nil;
	_adpurl = nil;
	_adpcontent = nil;
	adpdata = nil;
	addata = nil;
	[super dealloc];
}

@end
