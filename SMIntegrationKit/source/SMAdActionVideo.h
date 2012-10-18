
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SMAdActionBase.h"
#import "SMAdVideoBeaconData.h"
#import "defs.h"
#import "targeting.h"

@interface SMAdActionVideo : SMAdActionBase {
	NSDate * stEvent;
	NSDate * p25Event;
	NSDate * p50Event;
	NSDate * p75Event;
	NSDate * p100Event;
	Boolean firedStart;
	Boolean firedEnd;
	UIWindow * window;
	UIWebView * webview;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	MPMoviePlayerViewController * mplayer;
#else
	id mplayer;
#endif
	
	NSTimer * _beaconTimer;
}

@end
