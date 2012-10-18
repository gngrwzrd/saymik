
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMAd.h"
#import "SMAdIPrivate.h"
#import "SMAdRendererBase.h"
#import "SMAdUtility.h"
#import "SMAdBeacon.h"
#import "SMActionHandler.h"
#import "defs.h"

/**
 * The SMAdInterstitialRendererV1 is the interstitial renderer for ads that
 * have an MAB version string with a period in it - something like 1.5.6.
 * Those versions of the interstitials only supported iphone portrait, same
 * with this renderer - only iphone portrait.
 */

@interface SMAdInterstitialRendererV1 : SMAdRendererBase <UIWebViewDelegate> {
	Boolean toredown;
	Boolean hasEngaged;
	Boolean didHaveStatusbar;
	UIView * _container;
	UIViewController * _containervc;
	UIToolbar * _toolbar;
	UIWindow * _keyWindow;
	UIWindow * _takeoverWindow;
	UIWebView * _takeover;
}

- (id) init;
- (void) setupToolbar;
- (void) updateFrames;
- (void) teardown;
- (void) render;
- (void) setupToolbar;
- (void) closeTakeover;

@end
