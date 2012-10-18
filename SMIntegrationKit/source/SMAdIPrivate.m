
#import "SMAdIPrivate.h"

@implementation SMAdIPrivate

- (void) renderHouseAdWithInspector:(SMAdInspector *) inspector model:(SMAdModel *) model loader:(SMAdLoader *) loader {}
- (void) renderAdWithBannerView {}
- (void) failWithError:(_SMAdError) error {}
- (void) hideBannerTakeover {}
- (void) hideInterstitial {}
- (void) perror:(_SMAdError) error {}
- (void) registerForAppStateChanges {}
- (void) resetInternal {}
- (void) resetPrivateLoader:(SMAdPrivateLoader *) loader {}
- (void) requestAdForType:(SMAdType) type product:(NSString *) product {}
- (void) showLateBanner {}
- (Boolean) supportsOrientation:(UIDeviceOrientation) orientation {
	return false;
}
- (Boolean) inviteSupportsOrientation:(UIDeviceOrientation) orientation {
	return false;
}
- (Boolean) interstitialSupportsOrientation:(UIDeviceOrientation) orientation {
	return false;
}
- (Boolean) bannerAvailable {
	return false;
}
- (NSString *) serror:(_SMAdError) error {
	return @"";
}
+ (NSString *) IDKVersion {
	return @"";
}
- (NSTimeInterval) defaultAnimationDuration {
	return .1;
}

@end
