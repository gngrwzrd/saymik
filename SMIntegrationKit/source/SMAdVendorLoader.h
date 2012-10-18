
#include <time.h>
#include <regex.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JSON.h"

@class SMAdVendorLoader;

@protocol SMAdVendorLoaderDelegate
- (void) smAdVendorLoaderDidFinish:(SMAdVendorLoader *) loader;
- (void) smAdVendorLoaderDidFail:(SMAdVendorLoader *) loader;
@end

@interface SMAdVendorLoader : NSObject {
	BOOL error;
	NSObject <SMAdVendorLoaderDelegate> * _delegate;
	NSDate * _initEvent;
	NSDate * _amrStartEvent;
	NSDate * _amrEvent;
	NSString * _pui;
	NSString * _rid;
	NSString * _bid;
	NSString * _dim;
	NSString * _area;
	NSString * _adpurl;
	NSString * _adpcontent;
	NSString * _adurl;
	NSString * _adcontent;
	NSMutableData * _adpdata;
	NSMutableData * _addata;
	NSURLConnection * _adpconn;
	NSURLConnection * _adconn;
}

@property (nonatomic,assign) NSObject <SMAdVendorLoaderDelegate> * delegate;
@property (nonatomic,copy) NSString * area;
@property (nonatomic,copy) NSString * rid;
@property (nonatomic,copy) NSString * bid;
@property (nonatomic,copy) NSString * adcontent;
@property (nonatomic,copy) NSString * adurl;

/**
 * Load an ad with an AREA ID.
 */
- (void) loadAdWithArea:(NSString *) area;

/**
 * Check if the ad is a house ad.
 */
- (Boolean) isHouseAd;

/**
 * Show the banner for a web view that the adcontent has been loaded into.
 */
- (void) showLandscapeBannerForWebView:(UIWebView *) webview;

/**
 * Show the banner for a web view that the adcontent has been loaded into.
 */
- (void) showPortraitBannerForWebView:(UIWebView *) webview;

/**
 * Show the portrait takeover for a web view that the adcontent has been loaded into.
 */
- (void) showPortraitTakeoverForWebView:(UIWebView *) webview;

/**
 * Show the landscape takeover for a web view that the adcontent has been loaded into.
 */
- (void) showLandscapeTakeoverForWebView:(UIWebView *) webview;

/** internal **/
- (NSString *) genRid;
- (NSString *) urlencodeString:(NSString *) str;
- (void) loadAd;
- (void) finish;
- (void) fireBeacons;

@end
