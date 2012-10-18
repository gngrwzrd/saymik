
#import <Foundation/Foundation.h>

/**
 * The SMConfigPrivate class is the private interface to setting properties
 * on the Say Media integration config object that aren't public.
 */
@interface SMAdConfigPrivate : NSObject {
	
}

+ (void) resetConfig:(NSMutableDictionary *) config;
+ (void) loadLocalAd:(NSString *) adfile forConfig:(NSMutableDictionary *) config;
+ (void) loadRemoteAd:(NSString *) adurl forConfig:(NSMutableDictionary *) config;
+ (void) loadRemoteAdForBanner:(NSString *) adurl forConfig:(NSMutableDictionary *) config;
+ (void) loadRemoteAdForInterstitial:(NSString *) adurl forConfig:(NSMutableDictionary *) config;
+ (void) loadAdWithFCID:(NSString *) fcid andPlacementId:(NSString *) placement forConfig:(NSMutableDictionary *) config;
+ (void) loadAdWithFCID:(NSString *) fcid forConfig:(NSMutableDictionary *) config;
+ (void) loadInterstitialWithFCID:(NSString *) fcid forConfig:(NSMutableDictionary *) config;
+ (void) swipeBannerForNewAd:(NSMutableDictionary *) config;

@end
