
#import "SMAdTesterAppDelegate.h"
#import "SMAdTesterViewController.h"

@implementation SMAdTesterAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)
application:(UIApplication *) application
didFinishLaunchingWithOptions:(NSDictionary *) launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:true];
	[self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) dealloc {
	[viewController release];
	[window release];
	[super dealloc];
}

@end
