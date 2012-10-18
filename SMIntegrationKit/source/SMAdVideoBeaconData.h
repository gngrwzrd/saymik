
#import <Foundation/Foundation.h>
#import "defs.h"

@interface SMAdVideoBeaconData : NSObject {
	NSString * _curtime;
	NSString * _vidid;
	NSUInteger _timeInVideo;
	NSUInteger _videoPercent;
}

@property (nonatomic,copy) NSString * curtime;
@property (nonatomic,copy) NSString * vidid;
@property (nonatomic,assign) NSUInteger videoPercent;
@property (nonatomic,assign) NSUInteger timeInVideo;

@end
