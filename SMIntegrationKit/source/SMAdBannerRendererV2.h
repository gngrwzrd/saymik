
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "defs.h"
#import "targeting.h"
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
#import "SMAdViewController.h"
#import "Reachability.h"

@interface SMAdBannerRendererV2 : SMAdRendererBase <UIWebViewDelegate,SMAdTouchViewDelegate,UIAccelerometerDelegate> {
	float _inv_port_height;
	float _inv_land_height;
	float _device_width;
	float _device_height;
	int _device_rotate_right;
	int _device_rotate_left;
	Boolean invitePortrait;
	Boolean inviteLandscape;
	Boolean takeoverPortrait;
	Boolean takeoverLandscape;
	Boolean artworkIsLandscape;
	Boolean isportrait;
	Boolean hasEngaged;
	Boolean didHaveStatusbar;
	Boolean takeoverReady;
	Boolean firedThirdParty;
	Boolean isShaking;
	UIDeviceOrientation _orientation;
	NSDate * _backgroundEvent;
	UIScreen * _mainScreen;
	UIImageView * _bannerImageView;
	UIView * _black;
	UIView * _container;
	SMAdViewController * _containervc;
	UIWindow * _takeoverWindow;
	UIWindow * _keyWindow;
	UIWebView * _webview;
	NSMutableArray * _tpbs;
	UIAccelerometer * accel;
	UIAcceleration * last;
	SMAdTouchView * _touchView;
	NSObject <UIAccelerometerDelegate> * accelDelegate;
	Reachability * _reach;
}

- (void) closeTakeover;
- (void) closeTakeoverAnimated:(Boolean) animated;
- (void) closeTakeoverFinished;

@end
