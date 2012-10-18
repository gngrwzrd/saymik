
#import <Foundation/Foundation.h>
#import "defs.h"
#import "SMAdTPBDelegate.h"
#import "SMAdUtility.h"
#import "SMAdBeacon.h"

/**
 * Third Party Beacon Firing
 */

@interface SMAdTPB : NSObject <SMAdBeaconDelegate> {
	SMAdBeacon * _echoBeacon;
	NSObject <SMAdTPBDelegate> * _delegate;
	NSString * _url;
	NSURLConnection * conn;
}

@property (nonatomic,assign) NSObject <SMAdTPBDelegate> * delegate;
@property (nonatomic,copy) NSString * url;

- (id) initWithURLString:(NSString *) url;
- (void) send;

@end
