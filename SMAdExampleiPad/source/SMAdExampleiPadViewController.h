
#import <UIKit/UIKit.h>
#import "SMAd.h"

@interface SMAdExampleiPadViewController : UIViewController <SMAdDelegate> {
	SMAd * smad;
	NSMutableDictionary * config;
}

- (IBAction) onBanner;
- (IBAction) onInterstitial;

@end
