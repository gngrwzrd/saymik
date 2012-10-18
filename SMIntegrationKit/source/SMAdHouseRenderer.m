
#import "SMAdHouseRenderer.h"

@implementation SMAdHouseRenderer

- (void) render {
	//create beacons
	[self prepareBeacons];
	
	//update amr beacon for house ad
	[_model setCode:@"no"];
	[_model setReason:[_inspector reason]];
	[_amrBeacon setModel:_model];
	
	//send beacons
	[_initBeacon sendInit];
	[_amrBeacon sendAdModelReceived];
	[_echoBeacon sendEcho];
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdHouseRenderer");
	#endif
	[super dealloc];
}

@end
