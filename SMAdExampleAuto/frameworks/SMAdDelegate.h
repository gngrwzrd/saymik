
/****************************************************************** Forwards **/
@class SMAd;
@class SMAdBannerView;

/************************************************************** SMAdDelegate **/

@protocol SMAdDelegate
@optional

/**
 * Called when the banner is shown.
 */
- (void) smAdBannerShown:(SMAd *) ad;

/**
 * Called when the banner takeover is shown.
 */
- (void) smAdBannerTakeoverShown:(SMAd *) ad;

/**
 * Called when the banner takeover is hidden.
 */
- (void) smAdBannerTakeoverHidden:(SMAd *) ad;

/**
 * Called when the banner takeover is about to be hidden.
 */
- (void) smAdBannerTakeoverWillHide:(SMAd *) ad;

/**
 * Called when an interstitial ad is shown.
 */
- (void) smAdInterstitialShown:(SMAd *) ad;

/**
 * Called when an interstitial ad is hidden.
 */
- (void) smAdInterstitialHidden:(SMAd *) ad;

/**
 * Called when an interstitial ad is about to be hidden.
 */
- (void) smAdInterstitialWillHide:(SMAd *) ad;

/**
 * Called after a request for a banner ad is made and a banner is available.
 */
- (void) smAdBannerAvailable:(SMAd *) ad;

/**
 * Called after a request for a banner ad is made and a banner is available.
 * You also get passed an SMAdBannerView you can use as an alternative method
 * to displaying the banner.
 *
 * If you don't use this, you need to use smAdBannerAvailable: with the SMAd
 * displayInView: method.
 */
- (void) smAdBannerAvailable:(SMAd *) ad withBannerView:(SMAdBannerView *) view;

/**
 * Called to notify you that an interstitial is available.
 */
- (void) smAdInterstitialAvailable:(SMAd *) ad;

/**
 * Called to notify you that a banner is not available.
 */
- (void) smAdBannerNotAvailable:(SMAd *) ad;

/**
 * Called to notify you that an interstitial is not available.
 */
- (void) smAdInterstitialNotAvailable:(SMAd *) ad;

/**
 * Called to notify you that a request for a banner was made.
 */
- (void) smAdDidRequestBanner:(SMAd *) ad;

/**
 * Called to notify you that a request for an interstitial was made.
 */
- (void) smAdDidRequestInterstitial:(SMAd *) ad;

/**
 * Called to notify you of miscelaneous errors that aren't related to
 * ad serving. Like netork errors, etc. See the SMAdError enum in SMAd.h
 */
- (void) smAd:(SMAd *) ad failedWithError:(SMAdError) error;

@end
