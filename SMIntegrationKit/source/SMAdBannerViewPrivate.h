
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMAdRendererBase.h"

@interface SMAdBannerViewPrivate : NSObject {

}

- (id) _initWithFrame:(CGRect) frame;
- (void) setRenderer:(SMAdRendererBase <SMAdRenderer>*) renderer;
- (void) setOrientation:(UIDeviceOrientation) orientation;
- (void) _updateFrame;

@end
