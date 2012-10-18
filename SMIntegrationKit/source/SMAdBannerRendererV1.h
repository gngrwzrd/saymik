
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMAd.h"
#import "SMAdIPrivate.h"
#import "SMAdRenderer.h"
#import "SMActionHandler.h"
#import "SMAdAction.h"
#import "SMAdRendererBase.h"
#import "SMAdBeacon.h"
#import "SMAdTouchView.h"
#import "SMAdTouchViewDelegate.h"
#import "SMAdUtility.h"

/**
 * The SMAdRendererV1 is a renderer used when an ad's MAB version includes
 * a period in the version string - something like 1.5.6. That version of
 * the ad templates only supported iphone portrait ads - same with this
 * renderer, only iphone portrait.
 */

@interface SMAdBannerRendererV1 : SMAdRendererBase <UIWebViewDelegate,SMAdTouchViewDelegate> {
	Boolean isportrait;
	Boolean hasEngaged;
	Boolean didHaveStatusbar;
	UIDeviceOrientation _orientation;
	UIView * _container;
	UIViewController * _containervc;
	UIToolbar * _toolbar;
	UIWindow * _takeoverWindow;
	UIWindow * _keyWindow;
	UIWebView * _webview;
	UIWebView * _takeover;
	SMAdTouchView * _touchView;
}

- (id) init;
- (void) setupToolbar;
- (void) teardown;
- (void) render;
- (void) showTakeover;
- (void) hideStatusbar;
- (void) hideModals;
- (void) closeTakeover;
- (void) closeTakeoverAnimated:(Boolean) animated;
- (void) closeTakeoverFinished;
- (void) updateFramesForInvite;
- (void) updateFramesForTakeover;

@end
