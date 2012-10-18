
#import <Foundation/Foundation.h>
#import "SMAdAutoDelegate.h"

/**
 * The SMAdAuto class wraps an NSTimer to handle the auto updating
 * of banner ads.
 */
@interface SMAdAuto : NSObject {
	NSTimer * _timer;
	NSObject <SMAdAutoDelegate> * _delegate;
	NSTimeInterval _tickTime;
}

@property (nonatomic,assign) NSObject <SMAdAutoDelegate> * delegate;
@property (nonatomic,assign) NSTimeInterval tickTime;

- (void) start;
- (void) stop;
- (Boolean) isRunning;

@end
