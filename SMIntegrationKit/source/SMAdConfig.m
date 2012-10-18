
#import "SMAdConfig.h"
#import "SMAdConfigPrivate.h"

@implementation SMAdConfig

+ (void) setAreaId:(NSString *) areaid forConfig:(NSMutableDictionary *) config {
	[self setBannerAreaId:areaid forConfig:config];
	[self setInterstitialAreaId:areaid forConfig:config];
}

+ (void) setBannerAreaId:(NSString *) areaid forConfig:(NSMutableDictionary *) config {
	[config setObject:areaid forKey:@"bannerArea"];
}

+ (void) setInterstitialAreaId:(NSString *) areaid forConfig:(NSMutableDictionary *) config {
	[config setObject:areaid forKey:@"interstitialArea"];
}

@end
