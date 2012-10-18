
#import <UIKit/UIKit.h>
#import "SMAd.h"

@interface SMAdiPhoneViewController : UIViewController <SMAdDelegate> {
	SMAd * smad;
	NSMutableDictionary * config;
}

- (IBAction) onBanner;
- (IBAction) onInterstitial;

@end
