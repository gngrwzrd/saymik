
#import <Foundation/Foundation.h>
#import "AdWhirlView.h"
#import "AdWhirlAdNetworkConfig.h"
#import "AdWhirlAdNetworkAdapter+Helpers.h"
#import "AdWhirlAdNetworkRegistry.h"
#import "SMAd.h"

@interface AdWhirlAdapterSayMedia : AdWhirlAdNetworkAdapter <SMAdDelegate> {
	SMAd * smad;
	NSMutableDictionary * config;
}

@end
