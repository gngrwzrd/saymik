
#import <Foundation/Foundation.h>
#import "SMAdBeacon.h"
#import "SMAdRendererBase.h"
#import "SMAdBeaconDelegate.h"
#import "defs.h"

/**
 * The SMAdHouseRenderer is used when a house id is returned from the ad
 * server. All it does is fire beacons - because a house ad indicates that
 * there are no real ads to serve.
 */

@interface SMAdHouseRenderer : SMAdRendererBase {
	
}

@end
