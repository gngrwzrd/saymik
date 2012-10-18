
#import <Foundation/Foundation.h>

/**************************************************************** SMAdConfig **/

@interface SMAdConfig : NSObject {
}

/**
 * Set both the banner area id and the interstitial area id to the same
 * thing. If you were only give one area id, then use this method.
 */
+ (void) setAreaId:(NSString *) areaid forConfig:(NSMutableDictionary *) config;

/**
 * Set the banner area id for requesting banners.
 */
+ (void) setBannerAreaId:(NSString *) areaid forConfig:(NSMutableDictionary *) config;

/**
 * Set the interstitial area id for requesting interstitials.
 */
+ (void) setInterstitialAreaId:(NSString *) areaid forConfig:(NSMutableDictionary *) config;

@end
