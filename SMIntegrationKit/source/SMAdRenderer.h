
#import <UIKit/UIKit.h>

@protocol SMAdRenderer

@required
- (void) teardown;
- (void) render;
- (void) hideModals;
- (void) setOrientation:(UIDeviceOrientation) orientation updateFrames:(Boolean) update;
- (Boolean) isVisible;
- (Boolean) supportsOrientation:(UIDeviceOrientation) orientation;

@end
