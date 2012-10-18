
#import <UIKit/UIKit.h>

@class SMAdExampleAutoViewController;

@interface SMAdExampleAutoAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	SMAdExampleAutoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SMAdExampleAutoViewController *viewController;

@end
