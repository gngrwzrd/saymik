
#import "SMAdActionTPB.h"

@implementation SMAdActionTPB

- (void) execute {
	//prepare 3rd party request
	NSString * urls = [_message objectForKey:@"url"];
	if(!urls) urls = [_message objectForKey:@"href"];
	NSURL * ur = [NSURL URLWithString:urls];
	NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:ur];
	NSString * fmt = @"SMAdIntegrationKit-%.2f %@";
	NSString * device = [[UIDevice currentDevice] model];
	NSString * ua = [NSString stringWithFormat:fmt,(float)SMAdBeaconVersion,device];
	[req setValue:ua forHTTPHeaderField:@"User-Agent"];
	
	//send echo
	//_echoBeacon = [[SMAdBeacon alloc] init];
	//[_echoBeacon setModel:_model];
	//[_echoBeacon sendEchoWithURLAsBURL:urls];
	
	//send 3rd party
	if(conn) {
		[conn cancel];
		conn = nil;
	}
	conn = [[NSURLConnection connectionWithRequest:req delegate:self] retain];
	[conn start];
}

- (BOOL) requiresPersistence {
	return true;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionTPB");
	#endif
	[conn cancel];
	[conn release];
	[_echoBeacon release];
	_echoBeacon = nil;
	conn = nil;
	[super dealloc];
}

@end
