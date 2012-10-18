
#import "AdWhirlAdapterSayMedia.h"

@implementation AdWhirlAdapterSayMedia

+ (AdWhirlAdNetworkType) networkType {
	return AdWhirlAdNetworkTypeVideoEgg;
}

+ (void) load {
	[[AdWhirlAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void) getAd {
	if(!smad) smad = [[SMAd alloc] init];
	if(!config) config = [[NSMutableDictionary alloc] init];
	NSDictionary  * credentials = [networkConfig credentials];
	NSString * area = [credentials objectForKey:@"area"];
	if(!area) area = [credentials objectForKey:@"bannerArea"];
	if(area) [SMAdConfig setBannerAreaId:area forConfig:config];
	if([adWhirlDelegate respondsToSelector:@selector(smAdConfigNeedsUpdateForAdWhirl:)]) {
		[adWhirlDelegate performSelector:@selector(smAdConfigNeedsUpdateForAdWhirl:) withObject:config];
	}
	if(![config objectForKey:@"bannerArea"]) {
		NSLog(@"AdWhirl / Say Media Integration Error: An area id is not present");
		[adWhirlView adapter:self didFailAd:nil];
		return;
	}
	[smad setConfig:config];
	[smad setDelegate:self];
	[smad requestBanner];
}

- (void) smAdBannerNotAvailable:(SMAd *) ad {
	[adWhirlView adapter:self didFailAd:nil];
}

- (void) smAdBannerAvailable:(SMAd *) ad withBannerView:(SMAdBannerView *) view {
	[adWhirlView adapter:self didReceiveAdView:view];
}

- (void) smAdBannerTakeoverHidden:(SMAd *) ad {
	[self helperNotifyDelegateOfFullScreenModalDismissal];
}

- (void) smAdBannerTakeoverShown:(SMAd *) ad {
	[self helperNotifyDelegateOfFullScreenModal];
}

- (void) stopBeingDelegate {
}

- (void) dealloc {
	[smad release];
	[config release];
	smad = nil;
	config = nil;
	[super dealloc];
}

@end
