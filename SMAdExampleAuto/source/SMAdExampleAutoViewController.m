
#import "SMAdExampleAutoViewController.h"

@implementation SMAdExampleAutoViewController

- (void) viewDidLoad {
	smad = [[SMAd alloc] init];
	config = [[NSMutableDictionary alloc] init];
	[SMAdConfig setAreaId:@"IPHONE_SAY_TEST_BANNER" forConfig:config];
	[smad setConfig:config];
	[smad setDelegate:self];
	[smad setAutoUpdateInterval:15]; //default is 45 seconds. Minimum is 10 seconds
	[smad startAutoUpdateBannerAdsInView:[self view]];
	[super viewDidLoad];
}

- (void) smAdBannerNotAvailable:(SMAd *) ad {
	NSLog(@"banner not available. continuing.");
	[smad restartAutoUpdating];
}

- (void) dealloc {
	[smad release];
	[config release];
	smad = nil;
	config = nil;
    [super dealloc];
}

@end
