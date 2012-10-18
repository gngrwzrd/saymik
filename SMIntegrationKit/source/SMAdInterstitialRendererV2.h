
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMAd.h"
#import "SMAdIPrivate.h"
#import "SMAdRendererBase.h"
#import "SMAdUtility.h"
#import "SMAdBeacon.h"
#import "SMActionHandler.h"
#import "SMAdVideoBeaconData.h"
#import "Reachability.h"
#import "defs.h"

@interface SMAdInterstitialRendererV2 : SMAdRendererBase <UIWebViewDelegate,UIAccelerometerDelegate> {
	float _device_width;
	float _device_height;
	int _device_rotate_right;
	int _device_rotate_left;
	Boolean toredown;
	Boolean interstitialPortrait;
	Boolean interstitialLandscape;
	Boolean artworkIsLandscape;
	Boolean didHaveStatusbar;
	Boolean hasEngaged;
	Boolean isportrait;
	Boolean firedThirdParty;
	Boolean isShaking;
	UIDeviceOrientation _orientation;
	NSDate * _backgroundEvent;
	UIScreen * _mainScreen;
	UIView * _black;
	UIView * _container;
	UIViewController * _containervc;
	UIWindow * _keyWindow;
	UIWindow * _takeoverWindow;
	UIWebView * _takeover;
	NSMutableArray * _tpbs;
	UIAccelerometer * accel;
	UIAcceleration * last;
	NSObject <UIAccelerometerDelegate> * accelDelegate;
	Reachability * _reach;
}

- (void) teardown;
- (void) render;
- (void) closeTakeover;

@end
