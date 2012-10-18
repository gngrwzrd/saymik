
#import <UIKit/UIKit.h>

@class SMAdTPB;

@protocol SMAdTPBDelegate

- (void) tpbDidFinish:(SMAdTPB *) tpb;
- (void) tpbDidFail:(SMAdTPB *) tpb;

@end
