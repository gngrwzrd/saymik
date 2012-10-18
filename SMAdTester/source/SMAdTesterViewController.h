
#import <UIKit/UIKit.h>
#import "SMAd.h"
#import "SMAdIPrivate.h"
#import "SMAdConfig.h"
#import "SMAdConfigPrivate.h"

@interface SMAdTesterViewController : UIViewController <SMAdDelegate,UITextFieldDelegate> {
	SMAd * smad;
	NSDate * _date;
	UIDeviceOrientation _orientation;
	UIView * adcont;
	UIImageView * reddot;
	UITextField * fcid;
	UITextField * preview;
	UITextField * url;
	UITextField * area;
	UITextField * publisher;
	UITextField * intguid;
	UIButton * deallocb;
	UIButton * bbutton;
	UIButton * ibutton;
	NSMutableDictionary * config;
}

@property (nonatomic,retain) IBOutlet UIImageView * reddot;
@property (nonatomic,retain) IBOutlet UITextField * fcid;
@property (nonatomic,retain) IBOutlet UITextField * preview;
@property (nonatomic,retain) IBOutlet UITextField * url;
@property (nonatomic,retain) IBOutlet UITextField * intguid;
@property (nonatomic,retain) IBOutlet UITextField * area;
@property (nonatomic,retain) IBOutlet UITextField * publisher;
@property (nonatomic,retain) IBOutlet UIButton * deallocb;
@property (nonatomic,retain) IBOutlet UIButton * bbutton;
@property (nonatomic,retain) IBOutlet UIButton * ibutton;
@property (nonatomic,retain) IBOutlet UIView * adcont;

- (IBAction) onBanner;
- (IBAction) onAuto;
- (IBAction) onTween;
- (IBAction) onDealloc;
- (IBAction) onDefaults;
- (void) loadDefaults;

@end
