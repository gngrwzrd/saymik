
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SMAdActionBase.h"
#import "defs.h"

@interface VEActionVideo : SMAdActionBase {
	UIWindow * window;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	MPMoviePlayerViewController * mplayer;
#else
	id mplayer;
#endif

}

@end
