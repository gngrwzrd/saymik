
#import <Foundation/Foundation.h>

/**
 * The SMAdModel class stores key values for beacons,
 * and other random parameters that control the ad experience.
 * 
 * Parameters are all stored here so that objects need only
 * have a reference to the model to get keys and values.
 */
@interface SMAdModel : NSObject {
	Boolean _swipeForAdRequest;
	Boolean _isAdMeld;
	Boolean _isSMIntegrationDisabled;
	NSInteger _curtz;
	NSDate * _initEvent;
	NSDate * _adpStartEvent;
	NSDate * _adpEndEvent;
	NSDate * _adStartEvent;
	NSDate * _adEndEvent;
	NSString * _burl;
	NSString * _bid;
	NSString * _dim;
	NSString * _rid;
	NSString * _ccid;
	NSString * _code;
	NSString * _area;
	NSString * _lang;
	NSString * _pfam;
	NSString * _reason;
	NSString * _intgid;
	NSString * _product;
	NSString * _deviceId;
	NSString * _bannerArea;
	NSString * _interstitialArea;
	NSString * _loadLocalFile;
	NSString * _loadRemoteURL;
	NSString * _loadRemoteURLForInterstitial;
	NSString * _loadRemoteURLForBanner;
	NSString * _loadFCID;
	NSString * _loadPlacement;
	NSString * _loadInterFCID;
}

@property (nonatomic,assign) Boolean swipeForAdRequest;
@property (nonatomic,assign) Boolean isAdMeld;
@property (nonatomic,assign) Boolean isSMIntegrationDisabled;
@property (nonatomic,readonly) NSDate * initEvent;
@property (nonatomic,readonly) NSDate * adpStartEvent;
@property (nonatomic,readonly) NSDate * adpEndEvent;
@property (nonatomic,readonly) NSDate * adStartEvent;
@property (nonatomic,readonly) NSDate * adEndEvent;
@property (nonatomic,copy) NSString * bid;
@property (nonatomic,copy) NSString * dim;
@property (nonatomic,copy) NSString * rid;
@property (nonatomic,copy) NSString * ccid;
@property (nonatomic,copy) NSString * burl;
@property (nonatomic,copy) NSString * code;
@property (nonatomic,copy) NSString * area;
@property (nonatomic,copy) NSString * lang;
@property (nonatomic,copy) NSString * pfam;
@property (nonatomic,copy) NSString * reason;
@property (nonatomic,copy) NSString * intgid;
@property (nonatomic,copy) NSString * product;
@property (nonatomic,copy) NSString * deviceId;
@property (nonatomic,copy) NSString * bannerArea;
@property (nonatomic,copy) NSString * interstitialArea;
@property (nonatomic,copy) NSString * loadLocalFile;
@property (nonatomic,copy) NSString * loadRemoteURL;
@property (nonatomic,copy) NSString * loadRemoteURLForInterstitial;
@property (nonatomic,copy) NSString * loadRemoteURLForBanner;
@property (nonatomic,copy) NSString * loadFCID;
@property (nonatomic,copy) NSString * loadPlacement;
@property (nonatomic,copy) NSString * loadInterFCID;

- (void) updateFromConfig:(NSMutableDictionary *) config;
- (void) recordInitTime;
- (void) recordADPStart;
- (void) recordADPEnd;
- (void) recordADStart;
- (void) recordADEnd;
- (Boolean) isValidForType:(int) type;
- (NSString *) curtimezoneString;

@end
