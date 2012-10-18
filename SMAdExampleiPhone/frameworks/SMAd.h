
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMAdConfig.h"
#import "SMAdBannerView.h"

/***************************************************************** SMAdError **/

/**
 * SMAdError is an enum of possible errors that would get passed to the
 * SMAdDelegate method smAd:failedWithError:
 */
enum SMAdError {
	SMAdErrorNetworkError               = 1,
	SMAdErrorConfigNotSet               = 2,
	SMAdErrorInternalError              = 6,
};
typedef enum SMAdError SMAdError;

#import "SMAdDelegate.h"

/********************************************************************** SMAd **/

/**
 * The SMAd class is how you interact with the Say Media integration
 * kit.
 */
@interface SMAd : NSObject {
	void * internal;
	NSObject <SMAdDelegate> * _delegate;
}

/**
 *  SMAd delegate. 
 */
@property (nonatomic,assign) NSObject <SMAdDelegate> * delegate;

/**
 * Set the required config object for SMAdIntegrationKit.
 */
- (void) setConfig:(NSMutableDictionary *) config;

/**
 * Set the current orientation that the ads should be shown in.
 * If the ad doesn't support the orientation, it will default to
 * portrait. Say Media ads are guaranteed to support portrait.
 */
- (void) setOrientation:(UIDeviceOrientation) orientation;

/**
 * Request a banner ad from Say Media.
 */
- (void) requestBanner;

/**
 * Request an interstitial ad from Say Media.
 */
- (void) requestInterstitial;

/**
 * If you requested an interstitial and one is avaialable you
 * can call this method to show it.
 */
- (void) displayInterstitial;

/**
 * If you requested a banner and one is available you can call
 * this method to display it in a "container" view.
 */
- (void) displayBannerInView:(UIView *) view;

/**
 * The Say Media integration kit can request new banner ads for you
 * at a specified interval so you don't have to. Min = 10 seconds. It requires
 * you pass a container view that the ads will automatically update in.
 */
- (void) startAutoUpdateBannerAdsInView:(UIView *) view;

/**
 * Stop the auto banner updating. This completely clears the previous
 * view you were using for the auto updating. If you want to start
 * auto updates again after call this, you need to call 
 * "startAutoUpdateBannerAdsInView" to start the process over.
 */
- (void) stopAutoUpdateBannerAds;

/**
 * Pause the auto updater. The internal state is maintained and the
 * container view you passed in "startAutoUpdatingBannerAdsInView:" is
 * still used.
 */
- (void) pauseAutoUpdateBannerAds;

/**
 * Restarts the auto updater.
 */
- (void) restartAutoUpdating;

/**
 * Set the auto update interval. You should set this before calling
 * "startAutoUpdateBannerAdsInView:". The default is 45 seconds. Min = 10
 * seconds. There is no maximum.
 */
- (void) setAutoUpdateInterval:(NSTimeInterval) interval;

/**
 * This controls the animation time it takes to display the ad takeovers
 * or interstitials. Min = .1, Max = 2.
 */
- (void) setDefaultAnimationDuration:(NSTimeInterval) duration;

/**
 * Check whether an interstitial is available. This will only ever report true
 * if you previously called requestInterstitial and one is available.
 */
- (Boolean) interstitialAvailable;

@end
