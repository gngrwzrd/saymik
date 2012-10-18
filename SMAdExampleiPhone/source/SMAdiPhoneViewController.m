
#import "SMAdiPhoneViewController.h"

@implementation SMAdiPhoneViewController

- (void) viewDidLoad {
	smad = [[SMAd alloc] init];
	config = [[NSMutableDictionary alloc] init];
	[SMAdConfig setBannerAreaId:@"IPHONE_SAY_TEST_BANNER" forConfig:config];
	[SMAdConfig setInterstitialAreaId:@"IPHONE_SAY_TEST_INTER" forConfig:config];
	[smad setConfig:config];
	[smad setDelegate:self];
	[super viewDidLoad];
}

- (IBAction) onBanner {
	[smad requestBanner];
}

- (IBAction) onInterstitial {
	[smad requestInterstitial];
}

- (void) smAdBannerAvailable:(SMAd *) ad {
	[smad displayBannerInView:[self view]];
}

- (void) smAdBannerAvailable:(SMAd *) ad withBannerView:(SMAdBannerView *)view {
	NSLog(@"banner view!");
	NSLog(@"frame: w: %f, h: %f",view.frame.size.width,view.frame.size.height);
	[[self view] addSubview:view];
}

- (void) smAdInterstitialAvailable:(SMAd *) ad {
	[smad displayInterstitial];
}

- (void) smAdBannerNotAvailable:(SMAd *) ad {
	NSLog(@"no banner");
}

- (void) smAdInterstitialNotAvailable:(SMAd *) ad {
	NSLog(@"no interstitial");
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return TRUE;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[smad setOrientation:toInterfaceOrientation];
}

- (void) didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void) dealloc {
	[smad release];
	[config release];
	smad = nil;
	config = nil;
    [super dealloc];
}

@end
