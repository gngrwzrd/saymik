
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <regex.h>
#import "SMAdInspectorDelegate.h"
#import "SMAdUtility.h"

/**
 * The SMAdInspector class is used to inspect the contents of an ad
 * and help determine things like wether or not it's valid, as well
 * as using a web view to extract information from the ad content,
 * or sending messages to the web view.
 */
@interface SMAdInspector : NSObject <UIWebViewDelegate> {
	NSString * _adcontent;
	UIWebView * _webview;
	NSObject * _delegate;
	NSString * _reason;
	NSString * _ccid;
	NSString * _bcta;
	NSURL * _baseURL;
}

@property (nonatomic,copy) NSString * adcontent;
@property (nonatomic,assign) NSObject * delegate;
@property (nonatomic,retain) UIWebView * webview;
@property (nonatomic,readonly) NSString * reason;
@property (nonatomic,readonly) NSString * ccid;
@property (nonatomic,retain) NSURL * baseURL;

- (void) load;
- (void) sendBannerShownBeacon;
- (void) sendCloseBeacon;
- (void) sendEngagedBeacon;
- (void) sendScreenShownBeacon;
- (void) sendScreenHiddenBeacon;
- (void) landscape;
- (void) portrait;
- (void) setModelValue:(NSString *) value forKey:(NSString *) key;
- (void) sendScreenShownBeaconForUIWebView:(UIWebView *) view;
- (void) sendScreenHiddenBeaconForUIWebView:(UIWebView *) view;
- (void) setModelValue:(NSString *) value forKey:(NSString *) key forWebView:(UIWebView *) view;
- (void) sendCloseBeaconForUIWebView:(UIWebView *) view;
- (void) sendScreenHiddenBeaconWithCurtime:(NSTimeInterval) curtime;
- (void) sendScreenShownBeaconWithCurtime:(NSTimeInterval) curtime;
- (void) sendVideoStartWithCurtime:(NSString *) curtime andVidId:(NSString *) vidid;
- (void) sendTimeInVideoWithCurtime:(NSString *) curtime vidId:(NSString *) vidid timeInVideo:(NSUInteger) tiv videoPercent:(NSUInteger) percent;
- (void) adWasShown;
- (void) adWasDestroyed;
- (void) adBecameActive;
- (void) adBecameInactive;
- (Boolean) canSendSessionBeacons;
- (Boolean) canSendAppFocusBeacons;
- (Boolean) isValid;
- (Boolean) isNonMobileAd;
- (Boolean) isHouseAd;
- (Boolean) is3RDParty;
- (Boolean) isAdMeld;
- (Boolean) deviceMismatch;
- (Boolean) requiresOrientationEvents;
- (Boolean) isDeviceFamilyIOS;
- (Boolean) isOldCreative;
- (Boolean) inviteOrientationLandscape;
- (Boolean) inviteOrientationPortrait;
- (Boolean) takeoverOrientationPortrait;
- (Boolean) takeoverOrientationLandscape;
- (Boolean) interstitialPortrait;
- (Boolean) interstitialLandscape;
- (Boolean) artworkIsLandscape;
- (Boolean) disableInviteTouchView;
- (Boolean) requiresAccelerometerEvents;
- (Boolean) requiresShakeEvents;
- (Boolean) requiresNetworkStatus;
- (Boolean) requiresTwoWebViews;
- (NSString *) targetDevice;
- (NSString *) deviceFamily;
- (NSString *) getModelValueForKey:(NSString *) key;
- (NSString *) MABVersion;
- (NSString *) bannerCTAURL;
- (NSString *) renderVersion;
- (NSString *) adType;
- (NSString *) inviteOrientation;
- (NSString *) interstitialOrientation;
- (NSString *) takeoverOrientation;
- (NSString *) tpb;
- (NSString *) accelerometerFunctionName;
- (NSString *) shakeFunctionName;

@end
