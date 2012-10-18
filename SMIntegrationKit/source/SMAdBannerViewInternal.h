
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMAdRendererBase.h"
#import "SMAdRenderer.h"

struct SMAdBannerViewInternal {
	SMAdRendererBase <SMAdRenderer> * renderer;
	UIDeviceOrientation orientation;
};
typedef struct SMAdBannerViewInternal SMAdBannerViewInternal;
