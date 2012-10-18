
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/************************************************************ SMAdBannerView **/

/**
 * The SMAdBannerView is a view that contains the banner invite.
 *
 * You cannot instantiate this class directly. You're given one
 * when a banner ad is available. See the SMAdDelegate's
 * smAdBannerAvailable:withBannerView:
 */
@interface SMAdBannerView : UIView {
	void * _internal;
}

@end
