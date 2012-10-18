
#import "SMAdExampleOrientationViewController.h"

@implementation SMAdExampleOrientationViewController

- (void) viewDidLoad {
	smad = [[SMAd alloc] init];
	config = [[NSMutableDictionary alloc] init];
	[SMAdConfig setAreaId:@"IPHONE_SAY_TEST_BANNER" forConfig:config];
	[smad setConfig:config];
	[smad setDelegate:self];
	[smad setAutoUpdateInterval:15];
	[smad startAutoUpdateBannerAdsInView:[self view]];
	[super viewDidLoad];
}

- (void) smAdBannerNotAvailable:(SMAd *) ad {
	NSLog(@"banner not available. continuing");
	[smad restartAutoUpdating];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation duration:(NSTimeInterval) duration {
	[smad setOrientation:toInterfaceOrientation];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation {
	return YES;
}

- (void) dealloc {
	[super dealloc];
}

@end
