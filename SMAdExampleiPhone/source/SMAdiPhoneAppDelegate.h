
#import <UIKit/UIKit.h>

@class SMAdiPhoneViewController;

@interface SMAdiPhoneAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow * window;
	SMAdiPhoneViewController * viewController;
}

@property (nonatomic,retain) IBOutlet UIWindow * window;
@property (nonatomic,retain) IBOutlet SMAdiPhoneViewController * viewController;

@end

