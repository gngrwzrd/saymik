
#import "SMAdConfigPrivate.h"

@implementation SMAdConfigPrivate

+ (void) resetConfig:(NSMutableDictionary *) config {
	[config removeObjectForKey:@"local"];
	[config removeObjectForKey:@"remote"];
	[config removeObjectForKey:@"remoteBanner"];
	[config removeObjectForKey:@"remoteInterstitial"];
	[config removeObjectForKey:@"swipeForAdRequest"];
	[config removeObjectForKey:@"fcid"];
	[config removeObjectForKey:@"interfcid"];
	[config removeObjectForKey:@"placement"];
	[config removeObjectForKey:@"bannerArea"];
	[config removeObjectForKey:@"interstitialArea"];
}

+ (void) loadInterstitialWithFCID:(NSString *) fcid forConfig:(NSMutableDictionary *) config {
	[config setObject:fcid forKey:@"interfcid"];
}

+ (void) loadLocalAd:(NSString *) adfile forConfig:(NSMutableDictionary *) config {
	[config setObject:adfile forKey:@"local"];
}

+ (void) loadRemoteAd:(NSString *) adurl forConfig:(NSMutableDictionary *) config {
	[config setObject:adurl forKey:@"remote"];
}

+ (void) loadRemoteAdForBanner:(NSString *) adurl forConfig:(NSMutableDictionary *) config {
	[config setObject:adurl forKey:@"remoteBanner"];
}

+ (void) loadRemoteAdForInterstitial:(NSString *) adurl forConfig:(NSMutableDictionary *) config {
	[config setObject:adurl forKey:@"remoteInterstitial"];
}

+ (void) swipeBannerForNewAd:(NSMutableDictionary *) config {
	[config setObject:@"swipeForAdRequest" forKey:@"swipeForAdRequest"];
}

+ (void) loadAdWithFCID:(NSString *) fcid andPlacementId:(NSString *) placement forConfig:(NSMutableDictionary *) config {
	[config setObject:fcid forKey:@"fcid"];
	[config setObject:placement forKey:@"placement"];
}

+ (void) loadAdWithFCID:(NSString *) fcid forConfig:(NSMutableDictionary *) config {
	[config setObject:fcid forKey:@"fcid"];
}

@end
