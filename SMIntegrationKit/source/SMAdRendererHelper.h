
#import <Foundation/Foundation.h>
#import "defs.h"
#import "SMAdInspector.h"
#import "SMAdBannerRendererV1.h"
#import "SMAdHouseRenderer.h"
#import "SMAdInterstitialRendererV1.h"
#import "SMAdBannerRendererV2.h"
#import "SMAdUtility.h"
#import "SMAdInterstitialRendererV2.h"
#import "SMAdRendererAdMeld.h"
#import "SMAdModel.h"
#import "SMAdBannerRendererV2_2WebViews.h"

@interface SMAdRendererHelper : NSObject {

}

+ (Class) getRendererFromInspector:(SMAdInspector *) inspector model:(SMAdModel *) model type:(SMAdType) type;

@end
