
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "defs.h"
#import "SMAdError.h"

/**
 * The SMAdIPrivate object is only used for casts. These methods are actually
 * defined on the SMAd class but they aren't public. So you have to cast the
 * SMAd instance to an SMAdIPrivate to any methods listed in the interface.
 *
 * @example:
 * SMAdIPrivate * pad = (SMAdIPrivate *)smad;
 * [smad hideBannerTakeover];
 */
@interface SMAdIPrivate : NSObject {

}

+ (NSString *) IDKVersion;
- (void) renderHouseAdWithInspector:(SMAdInspector *) inspector model:(SMAdModel *) model loader:(SMAdLoader *) loader;
- (void) renderAdWithBannerView;
- (void) registerForAppStateChanges;
- (void) resetInternal;
- (void) resetPrivateLoader:(SMAdPrivateLoader *) loader;
- (void) requestAdForType:(SMAdType) type product:(NSString *) product;
- (void) failWithError:(_SMAdError) error;
- (void) hideBannerTakeover;
- (void) hideInterstitial;
- (void) perror:(_SMAdError) error;
- (void) showLateBanner;
- (Boolean) supportsOrientation:(UIDeviceOrientation) orientation;
- (Boolean) inviteSupportsOrientation:(UIDeviceOrientation) orientation;
- (Boolean) interstitialSupportsOrientation:(UIDeviceOrientation) orientation;
- (Boolean) bannerAvailable;
- (NSString *) serror:(_SMAdError) error;
- (NSTimeInterval) defaultAnimationDuration;

@end
