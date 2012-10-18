
#import <UIKit/UIKit.h>

#ifndef defs_h
#define defs_h

#import "SMAdLoader.h"
#import "SMAdError.h"
#import "SMAdInspector.h"
#import "SMAdRenderer.h"
#import "SMAdRendererBase.h"
#import "SMAdAuto.h"
#import "SMAdModel.h"

//the real integration kit version.
#define SMAdVersion @"2.0.5"

//the version sent in beacons. this should always be the major version of the
//current integration kit version.
#define SMAdBeaconVersion 2.0

//product codes.
#define SMAdProductBanner @"mobile"
#define SMAdProductTwixt  @"twixt"

//dim codes.
#define SMAdDimCode_iPhoneBanner @"iphone_standard"
#define SMAdDimCode_iPadBanner @"ipad_standard"
#define SMAdDimCode_iPhoneInter @"iphone_interstitial"
#define SMAdDimCode_iPadInter @"ipad_interstitial"

//uncomment this to turn on NSLog in dealloc methods.
//#define SMAdPrintDeallocs 1

#define degreesToRadians(x) (M_PI * x / 180.0)

//ad types
enum SMAdType {
	SMAdTypeHouse   = 1,
	SMAdTypeBanner  = 2,
	SMAdTypeTwixt   = 3,
};
typedef enum SMAdType SMAdType;

//structure to store objects that need seperate instances per ad load request.
struct SMAdPrivateLoader {
	SMAdModel * model;
	SMAdLoader * loader;
	SMAdInspector * inspector;
	SMAdRendererBase <SMAdRenderer> * active;
	SMAdBeacon * errbeacon;
};
typedef struct SMAdPrivateLoader SMAdPrivateLoader;

//private structure that the SMAd._internal pointer references.
struct SMAdPrivate {
	NSInteger loads;
	Boolean shouldDealloc;
	Boolean isSMIntegrationDisabled;
	Boolean bannerWasInTakeover;
	Boolean requestedBanner;
	Boolean requestedInterstitial;
	Boolean resumeAutoFromAppBG;
	Boolean didGoBG;
	NSMutableDictionary * config;
	UIView * autoUpdateInviteView;
	NSTimeInterval autoUpdateInterval;
	NSTimeInterval animationDuration;
	UIDeviceOrientation orientation;
	SMAdAuto * autoUpdater;
	SMAdBannerView * bannerView;
	SMAdPrivateLoader * houseLoader;
	SMAdPrivateLoader * bannerLoader;
	SMAdPrivateLoader * interstitialLoader;
	SMAdRendererBase <SMAdRenderer> * hactive;
	SMAdRendererBase <SMAdRenderer> * hinactive;
	SMAdBeacon * initBeacon;
};
typedef struct SMAdPrivate SMAdPrivate;

#endif
