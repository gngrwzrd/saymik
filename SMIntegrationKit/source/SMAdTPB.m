
#import "SMAdTPB.h"

@implementation SMAdTPB
@synthesize url = _url;
@synthesize delegate = _delegate;

- (id) initWithURLString:(NSString *) url {
	if(!(self = [super init])) return nil;
	_echoBeacon = [[SMAdBeacon alloc] init];
	//[_echoBeacon setAdurl:url];
	[_echoBeacon setDelegate:self];
	[self setUrl:url];
	return self;
}

- (void) send {
	NSURL * ur = [NSURL URLWithString:_url];
	NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:ur];
	NSString * fmt = @"SMAdIntegrationKit-%i %@";
	NSString * device = [[UIDevice currentDevice] model];
	NSString * ua = [NSString stringWithFormat:fmt,SMAdBeaconVersion,device];
	[req setValue:ua forHTTPHeaderField:@"User-Agent"];
	if(conn) {
		[conn cancel];
		conn = nil;
	}
	conn = [[NSURLConnection connectionWithRequest:req delegate:self] retain];
	[conn start];
}

- (void) connectionDidFinishLoading:(NSURLConnection *) connection {
	[_echoBeacon sendEcho];
}

- (void) connection:(NSURLConnection *) connection didFailWithError:(NSError *) error {
	if(_delegate && [_delegate respondsToSelector:@selector(tpbDidFail:)]) {
		[_delegate tpbDidFail:self];
	}
}

- (void) beaconDidFail:(SMAdBeacon *) becon {
	if(_delegate && [_delegate respondsToSelector:@selector(tpbDidFail:)]) {
		[_delegate tpbDidFail:self];
	}
}

- (void) beaconDidFinish:(SMAdBeacon *) beacon {
	if(_delegate && [_delegate respondsToSelector:@selector(tpbDidFinish:)]) {
		[_delegate tpbDidFinish:self];
	}
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdTPB");
	#endif
	[_url release];
	[conn cancel];
	[_echoBeacon release];
	_echoBeacon = nil;
	conn = nil;
	_url = nil;
	_delegate = nil;
	[super dealloc];
}

@end
