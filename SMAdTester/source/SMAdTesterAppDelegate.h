
#import <UIKit/UIKit.h>

@class SMAdTesterViewController;

@interface SMAdTesterAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SMAdTesterViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SMAdTesterViewController *viewController;

@end

