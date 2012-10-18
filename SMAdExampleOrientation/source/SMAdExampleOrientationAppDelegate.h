
#import <UIKit/UIKit.h>

@class SMAdExampleOrientationViewController;

@interface SMAdExampleOrientationAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SMAdExampleOrientationViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SMAdExampleOrientationViewController *viewController;

@end

