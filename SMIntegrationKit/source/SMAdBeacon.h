
#include <math.h>
#import <Foundation/Foundation.h>
#import "defs.h"
#import "SMAdBeaconDelegate.h"
#import "SMAdModel.h"

/**
 * The SMAdBeacon class is an abstracted way to send a few beacons. There
 * are only a few beacons that the integraion kit has to be able to fire.
 */
@interface SMAdBeacon : NSObject {
	Boolean _first;
	Boolean _err;
	Boolean _allowBeacons;
	NSInteger attempts;
	NSObject <SMAdBeaconDelegate> * _delegate;
	NSString * _beacon;
	NSURLConnection * bconn;
	NSString * _fileurl;
	SMAdModel * _model;
}

@property (nonatomic,assign) Boolean allowBeacons;
@property (nonatomic,assign) NSObject <SMAdBeaconDelegate> * delegate;
@property (nonatomic,assign) SMAdModel * model;
@property (nonatomic,copy) NSString * fileurl;

- (void) sendInit;
- (void) sendEcho;
- (void) sendAdModelReceived;
- (void) sendClose;
- (void) send;
- (void) sendEngagedWithContext:(NSString *) context;
- (void) sendEchoWithURLAsBURL:(NSString *) burl;

- (void) sendInvalidAdModel;
- (void) sendDeviceMismatch;
- (void) sendIntegrationMismatch;
- (void) sendNonMobile;
- (void) sendAdModelTimeout;

@end
