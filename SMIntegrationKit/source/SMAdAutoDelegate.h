
#import <UIKit/UIKit.h>

@class SMAdAuto;

@protocol SMAdAutoDelegate

@optional
- (void) autoDidTick:(SMAdAuto *) autob;

@end
