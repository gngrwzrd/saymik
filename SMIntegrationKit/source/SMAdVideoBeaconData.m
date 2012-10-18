
#import "SMAdVideoBeaconData.h"

@implementation SMAdVideoBeaconData
@synthesize curtime = _curtime;
@synthesize vidid = _vidid;
@synthesize timeInVideo = _timeInVideo;
@synthesize videoPercent = _videoPercent;

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdVideoBeaconData");
	#endif
	[super dealloc];
}

@end
