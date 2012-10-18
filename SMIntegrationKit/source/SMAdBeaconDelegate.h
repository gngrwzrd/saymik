
#import <UIKit/UIKit.h>

@class SMAdBeacon;

@protocol SMAdBeaconDelegate

- (void) beaconDidFail:(SMAdBeacon *) becon;
- (void) beaconDidFinish:(SMAdBeacon *) beacon;

@end
