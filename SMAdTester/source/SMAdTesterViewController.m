
#import "SMAdTesterViewController.h"

@implementation SMAdTesterViewController
@synthesize reddot;
@synthesize bbutton;
@synthesize ibutton;
@synthesize deallocb;
@synthesize preview;
@synthesize fcid;
@synthesize adcont;
@synthesize url;
@synthesize area;
@synthesize publisher;
@synthesize intguid;

- (void) viewDidLoad {
	[super viewDidLoad];
	_orientation = UIDeviceOrientationPortrait;
	_date = [[NSDate date] retain];
	[url setDelegate:self];
	[fcid setDelegate:self];
	[area setDelegate:self];
	[publisher setDelegate:self];
	[intguid setDelegate:self];
	[preview setDelegate:self];
	[reddot setAlpha:.2];
	[self loadDefaults];
}

- (void) loadDefaults {
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	[url setText:[defaults objectForKey:@"url"]];
	[area setText:[defaults objectForKey:@"area"]];
	[publisher setText:[defaults objectForKey:@"publisher"]];
	[fcid setText:[defaults objectForKey:@"fcid"]];
	[intguid setText:[defaults objectForKey:@"intguid"]];
	[preview setText:[defaults objectForKey:@"preview"]];
}

- (void) resignTextfields {
	[url resignFirstResponder];
	[fcid resignFirstResponder];
	[preview resignFirstResponder];
	[intguid resignFirstResponder];
	[publisher resignFirstResponder];
	[area resignFirstResponder];
}

- (IBAction) onDefaults {
	NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
	NSString * urltv = [url text];
	NSString * areatv = [area text];
	NSString * pubtv = [publisher text];
	NSString * fcidtv = [fcid text];
	NSString * prtv = [preview text];
	[def setValue:areatv forKey:@"area"];
	[def setValue:pubtv forKey:@"publisher"];
	[def setValue:urltv forKey:@"url"];
	[def setValue:fcidtv forKey:@"fcid"];
	[def setValue:prtv forKey:@"preview"];
	[def synchronize];
}

- (IBAction) onDealloc {
	NSDate * now = [NSDate date];
	NSTimeInterval nti = [now timeIntervalSince1970]*1000;
	NSTimeInterval dti = [_date timeIntervalSince1970]*1000;
	float diff = nti - dti;
	if(diff > 100 && diff < 400) {
		[url setText:@""];
		[fcid setText:@""];
		[preview setText:@""];
		[area setText:@""];
		[publisher setText:@""];
		[intguid setText:@""];
	}
	[_date release];
	_date = [now retain];
	[self resignTextfields];
	[reddot setAlpha:.2];
	[ibutton setEnabled:true];
	[ibutton setAlpha:1];
	[bbutton setEnabled:true];
	[bbutton setAlpha:1];
	if(smad) {
		[smad release];
		[config release];
		smad = nil;
		config = nil;
	}
}

- (void) updateSMAdWithRequestedType:(int) type {
	NSString * urltv = [url text];
	NSString * areatv = [area text];
	NSString * pubtv = [publisher text];
	NSString * fcids = [fcid text];
	NSString * prtv = [preview text];
	NSString * prurl = @"http://clientpreview.videoegg.com/mobile.php?pid=%@";
	
	if(config) {
		[config release];
		config = nil;
	}
	if(!smad) smad = [[SMAd alloc] init];
	
	if(type == 1 && [pubtv length] > 0) {
		config = [[NSMutableDictionary alloc] init];
		[SMAdConfig setInterstitialAreaId:pubtv forConfig:config];
		goto finish_smad;
	}
	
	if(type == 0 && [areatv length] > 0) {
		if(!config) config = [[NSMutableDictionary alloc] init];
		[SMAdConfig setBannerAreaId:areatv forConfig:config];
		goto finish_smad;
	}
	
	if([fcids length] > 0) {
		config = [[NSMutableDictionary alloc] init];
		//Boolean ispad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
		if([prtv length] > 0) [SMAdConfigPrivate loadAdWithFCID:fcids andPlacementId:prtv forConfig:config];
		else [SMAdConfigPrivate loadAdWithFCID:fcids forConfig:config];
		/*} else if(type == 0) {
			if(ispad) [SMAdConfigPrivate loadAdWithFCID:fcids andPlacementId:@"1891486" forConfig:config];
			else [SMAdConfigPrivate loadAdWithFCID:fcids andPlacementId:@"1891485" forConfig:config];
		} else if(type == 1) {
			if(ispad) [SMAdConfigPrivate loadAdWithFCID:fcids andPlacementId:@"1891487" forConfig:config];
			else [SMAdConfigPrivate loadAdWithFCID:fcids andPlacementId:@"1891488" forConfig:config];
		}*/
		goto finish_smad;
	}
	
	if([prtv length] > 0) {
		NSString * p = [NSString stringWithFormat:prurl,prtv];
		config = [[NSMutableDictionary alloc] init];
		[SMAdConfigPrivate loadRemoteAd:p forConfig:config];
		goto finish_smad;
	}
	
	if([urltv length] > 0) {
		config = [[NSMutableDictionary alloc] init];
		[SMAdConfigPrivate loadRemoteAd:urltv forConfig:config];
		goto finish_smad;
	}
	
	finish_smad:
	[SMAdConfigPrivate swipeBannerForNewAd:config];
	[smad setOrientation:_orientation];
	[smad setConfig:config];
	[smad setDelegate:self];
}

- (void) updateButtonsForRequest {
	[bbutton setEnabled:false];
	[bbutton setAlpha:.1];
	[ibutton setEnabled:false];
	[ibutton setAlpha:.1];
}

- (void) updateButtonsOnAvailable {
	[ibutton setEnabled:true];
	[ibutton setAlpha:1];
	[bbutton setEnabled:true];
	[bbutton setAlpha:1];
	[reddot setAlpha:.2];
}

- (void) updateButtonsOnNotAvailable {
	[reddot setAlpha:1];
	[bbutton setEnabled:true];
	[bbutton setAlpha:1];
	[ibutton setEnabled:true];
	[ibutton setAlpha:1];
}

- (IBAction) onAuto {
	[smad startAutoUpdateBannerAdsInView:adcont];
}

- (IBAction) onBanner {
	[self updateButtonsForRequest];
	[self resignTextfields];
	[self updateSMAdWithRequestedType:0];
	[smad requestBanner];
}

- (IBAction) onTween {
	[self updateButtonsForRequest];
	[self resignTextfields];
	[self updateSMAdWithRequestedType:1];
	[smad requestInterstitial];
}

/*- (void) smAdBannerAvailable:(SMAd *) ad withBannerView:(SMAdBannerView *) view {
	NSLog(@"%@",view);
	[self updateButtonsOnAvailable];
	[adcont addSubview:(UIView *)view];
}*/

- (void) smAdBannerAvailable:(SMAd *) ad {
	[self updateButtonsOnAvailable];
	[smad displayBannerInView:adcont];
}

- (void) smAdInterstitialAvailable:(SMAd *) ad {
	[self updateButtonsOnAvailable];
	[smad displayInterstitial];
}

- (void) smAdBannerNotAvailable:(SMAd *) ad {
	[self updateButtonsOnNotAvailable];
}

- (void) smAdInterstitialNotAvailable:(SMAd *) ad {
	[self updateButtonsOnNotAvailable];
}

- (void) smAdDidRequestBanner:(SMAd *) ad {
	[reddot setAlpha:.2];
}

- (void) smAdDidRequestIntersticial:(SMAd *) ad {
	[reddot setAlpha:.2];
}

- (void) smAdBannerTakeoverWillHide:(SMAd *) ad {

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	Boolean isphone = true;
	if([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)]) {
		isphone = !([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
	}
#else
	Boolean isphone = false;
#endif
	
	Boolean isportrait = _orientation == UIDeviceOrientationPortrait || _orientation == UIDeviceOrientationPortraitUpsideDown;
	if(isphone && isportrait) [[self view] setFrame:CGRectMake(0,0,320,480)];
	else if(isphone && !isportrait) [[self view] setFrame:CGRectMake(0,0,480,320)];
	else if(!isphone && isportrait) [[self view] setFrame:CGRectMake(0,0,768,1024)];
	else if(!isphone && !isportrait) [[self view] setFrame:CGRectMake(0,0,1024,768)];
}

- (void) smAdBannerTakeoverHidden:(SMAd *) ad {
	
}

- (void) smAd:(SMAd *) ad failedWithError:(SMAdError) error {
	[self updateButtonsOnNotAvailable];
	[reddot setAlpha:.2];
	NSString * serror = [(SMAdIPrivate *)smad serror:error];
	UIAlertView * alert = [[UIAlertView alloc] init];
	[alert setMessage:serror];
	[alert addButtonWithTitle:@"OK"];
	[alert show];
	[alert release];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation {
	return true;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	Boolean isphone = true;
	if([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)]) {
		isphone = !([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
	}
#else
	Boolean isphone = false;
#endif
	
	if(UIDeviceOrientationIsPortrait(_orientation)) {
		if(isphone) [[self view] setFrame:CGRectMake(0,0,320,480)];
		else [[self view] setFrame:CGRectMake(0,0,768,1024)];
	}
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation duration:(NSTimeInterval) duration {
	_orientation = [[UIDevice currentDevice] orientation];
	[smad setOrientation:_orientation];
}

- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event {
	[self resignTextfields];
}

- (BOOL) textFieldShouldReturn:(UITextField *) textField {
	[self resignTextfields];
	[self onBanner];
	return false;
}

- (void) didReceiveMemoryWarning {
	NSLog(@"mem warning!");
	[super didReceiveMemoryWarning];
}

- (void) dealloc {
	[smad release];
	[config release];
	[super dealloc];
}

@end
