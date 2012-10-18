
#include <time.h>
#import <CommonCrypto/CommonDigest.h>
#import "defs.h"
#import "SMAd.h"
#import "SMAdIPrivate.h"
#import "SMAdModel.h"
#import "SMAdBannerView.h"
#import "SMAdBannerViewPrivate.h"
#import "SMAdLoader.h"
#import "SMAdRendererBase.h"
#import "SMAdRendererHelper.h"

NSString * MD5Hash(NSString * concat) {
	const char *concat_str = [concat UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(concat_str, strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

@implementation SMAd
@synthesize delegate = _delegate;

+ (NSString *) IDKVersion {
	return SMAdVersion;
}

- (id) init {
	if(!(self = [super init])) return nil;
	
	//initialize internal private structure.
	internal = calloc(1,(sizeof(SMAdPrivate)));
	if(!internal) {
		perror("!SMAdd.initWithConfig.internal");
		return nil;
	}
	
	//setup typed reference
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	
	//register for app background / foreground
	[(SMAdIPrivate *)self registerForAppStateChanges];
	
	//check for disabled integration kit. if the integration kit is
	//disabled the ik will always return an ad - but any requests
	//to display an ad will do nothing.
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	NSDictionary * domain = [defaults persistentDomainForName:NSGlobalDomain];
	if([domain objectForKey:@"__isSMIntegrationDisabled__"]) {
		_internal->isSMIntegrationDisabled = [[domain objectForKey:@"__isSMIntegrationDisabled__"] boolValue];
	}
	_internal->isSMIntegrationDisabled = false;
	
	//setup private loader structures
	_internal->bannerLoader = calloc(1,sizeof(SMAdPrivateLoader));
	_internal->interstitialLoader = calloc(1,sizeof(SMAdPrivateLoader));
	_internal->houseLoader = calloc(1,sizeof(SMAdPrivateLoader));
	_internal->bannerLoader->errbeacon = [[SMAdBeacon alloc] init];
	_internal->interstitialLoader->errbeacon = [[SMAdBeacon alloc] init];
	
	//set defaults
	_internal->animationDuration = .27;
	_internal->orientation = UIDeviceOrientationPortrait;
	_internal->autoUpdateInterval = 45;
	_internal->loads = 0;
	return self;
}

- (void) failWithError:(_SMAdError) err {
	[(SMAdIPrivate*)self perror:err];
	if(_delegate && [_delegate \
	respondsToSelector:@selector(smAd:failedWithError:)])
	{
		[_delegate smAd:self failedWithError:err];
	}
}

- (void) _adNotAvailableForType:(SMAdType) type {
	if(type == SMAdTypeBanner) {
		if(_delegate && [_delegate \
			respondsToSelector:@selector(smAdBannerNotAvailable:)])
		{
			[_delegate smAdBannerNotAvailable:self];
		}
	} else if(type == SMAdTypeTwixt) {
		if(_delegate && [_delegate \
			respondsToSelector:@selector(smAdInterstitialNotAvailable:)])
		{
			[_delegate smAdInterstitialNotAvailable:self];
		}
	}
}

- (void) _adAvailableForType:(SMAdType) type {
	if(type == SMAdTypeBanner) {
		if(_delegate && [_delegate \
			respondsToSelector:@selector(smAdBannerAvailable:)])
		{
			[_delegate smAdBannerAvailable:self];
		}
	}
	if(type == SMAdTypeTwixt) {
		if(_delegate && [_delegate \
			respondsToSelector:@selector(smAdInterstitialAvailable:)])
		{
			[_delegate smAdInterstitialAvailable:self];
		}
	}
}

- (void) requestBanner {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	
	//check if a delayed banner can be shown
	if(_internal->bannerWasInTakeover) {
		_internal->bannerWasInTakeover = false;
		[self _adAvailableForType:SMAdTypeBanner];
		return;
	}
	
	//check if there's already a loader working - if so we're
	//already requesting a banner
	if(_internal->bannerLoader && _internal->bannerLoader->loader) return;
	
	//check for disabled integration kit. if it's disabled we report that
	//we have an ad so that nothing shows up.
	if(_internal->isSMIntegrationDisabled) {
		[self _adAvailableForType:SMAdTypeBanner];
		return;
	}
	
	//check if we're auto updating - if so wait for the auto updater to
	//request the ad rather than the public interface doing it.
	if(_internal->autoUpdater) return;
	
	//set request banner
	if(_internal->requestedBanner) return;
	_internal->requestedBanner = TRUE;
	
	//make request
	[(SMAdIPrivate *)self requestAdForType:SMAdTypeBanner product:SMAdProductBanner];
	if(_delegate && [_delegate \
		respondsToSelector:@selector(smAdDidRequestBanner:)])
	{
		[_delegate smAdDidRequestBanner:self];
	}
}

- (void) __requestBanner {
	//NSLog(@"__request banner!");
	
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	
	//check if a delayed banner can be shown
	if(_internal->bannerWasInTakeover) {
		_internal->bannerWasInTakeover = false;
		[self _adAvailableForType:SMAdTypeBanner];
		return;
	}
	
	//check if there's already a loader working - if so we're
	//already requesting a banner
	if(_internal->bannerLoader && _internal->bannerLoader->loader) return;
	
	//set request banner
	if(_internal->requestedBanner) return;
	_internal->requestedBanner = TRUE;
	
	//request
	[(SMAdIPrivate *)self requestAdForType:SMAdTypeBanner product:SMAdProductBanner];
	if(_delegate && [_delegate \
		respondsToSelector:@selector(smAdDidRequestBanner:)])
	{
		[_delegate smAdDidRequestBanner:self];
	}
}

- (void) requestInterstitial {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	
	//check for requested interstitial
	if(_internal->requestedInterstitial) return;
	
	//check if there's already a loader working - if so we're
	//already requesting a banner
	if(_internal->interstitialLoader && _internal->interstitialLoader->loader) {
		[self _adAvailableForType:SMAdTypeTwixt];
		return;
	}
	
	//check for disabled integration kit. if it's disabled we report that
	//we have an ad so that nothing shows up
	if(_internal->isSMIntegrationDisabled) {
		[self _adAvailableForType:SMAdTypeBanner];
		return;
	}
	
	//set requested interstitial
	_internal->requestedInterstitial = TRUE;
	
	//make request
	[(SMAdIPrivate *)self requestAdForType:SMAdTypeTwixt product:SMAdProductTwixt];
	if(_delegate && [_delegate \
		respondsToSelector:@selector(smAdDidRequestInterstitial:)])
	{
		[_delegate smAdDidRequestInterstitial:self];
	}
}

- (void) requestAdForType:(SMAdType) type product:(NSString *) product {
	//check for internal structure
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(!_internal) {
		[(SMAdIPrivate *)self perror:_SMAdErrorInternalError];
		return;
	}
	
	//check for config
	if(!_internal->config) {
		[self failWithError:_SMAdErrorConfigNotSet];
		return;
	}
	
	//setup vars
	//SMAdPrivateLoader * ploader = NULL;
	SMAdModel * model = NULL;
	SMAdLoader * loader = NULL;
	Boolean isphone = ![SMAdUtility isPad];
	SMAdPrivateLoader * ploader = NULL;
	
	//select vars
	if(type == SMAdTypeBanner) {
		//ploader = _internal->bannerLoader;
		_internal->bannerLoader->model = [[SMAdModel alloc] init];
		_internal->bannerLoader->loader = [[SMAdLoader alloc] init];
		_internal->bannerLoader->inspector = [[SMAdInspector alloc] init];
		model = _internal->bannerLoader->model;
		loader = _internal->bannerLoader->loader;
		ploader = _internal->bannerLoader;
	} else if(type == SMAdTypeTwixt) {
		//ploader = _internal->interstitialLoader;
		_internal->interstitialLoader->model = [[SMAdModel alloc] init];
		_internal->interstitialLoader->loader = [[SMAdLoader alloc] init];
		_internal->interstitialLoader->inspector = [[SMAdInspector alloc] init];
		model = _internal->interstitialLoader->model;
		loader = _internal->interstitialLoader->loader;
		ploader = _internal->interstitialLoader;
	}
	
	//update model
	//srand(10);
	//unsigned int r = rand();
	NSString * fmt = @"%lu%@";
	NSString * bid = [[NSBundle mainBundle] bundleIdentifier];
	NSString * did = MD5Hash([UIDevice currentDevice].uniqueIdentifier);
	NSString * rid = [NSString stringWithFormat:fmt,time(NULL),did];
	NSString * md5rid = MD5Hash(rid);
	//NSLog(@"rid: %@",md5rid);
	NSString * dim = SMAdDimCode_iPhoneBanner;
	if(isphone && type == SMAdTypeTwixt) dim = SMAdDimCode_iPhoneInter;
	if(!isphone && type == SMAdTypeTwixt) dim = SMAdDimCode_iPadInter;
	if(!isphone && type == SMAdTypeBanner) dim = SMAdDimCode_iPadBanner;
	[model updateFromConfig:_internal->config];
	[model recordInitTime];
	[model setDeviceId:did];
	[model setProduct:product];
	[model setBid:bid];
	[model setRid:md5rid];
	[model setDim:dim];
	if(type == SMAdTypeBanner) [model setArea:[model bannerArea]];
	else if(type == SMAdTypeTwixt) [model setArea:[model interstitialArea]];
	
	//fire init beacon.
	//if(!_internal->initBeacon) _internal->initBeacon = [[SMAdBeacon alloc] init];
	//[_internal->initBeacon setModel:model];
	//[_internal->initBeacon sendInit];
	
	//check for valid model
	if(![model isValidForType:type]) {
		if(ploader) {
			[ploader->errbeacon setModel:ploader->model];
			[ploader->errbeacon sendInit];
			[ploader->errbeacon sendEcho];
			[ploader->errbeacon sendInvalidAdModel];
		}
		_internal->requestedInterstitial = FALSE;
		[self failWithError:_SMAdErrorConfigNotSet];
		//[(SMAdIPrivate *)self resetPrivateLoader:ploader];
		[model release];
		[loader release];
		return;
	}
	
	//increment load count for late deallocation
	_internal->loads++;
	
	//load ad
	[loader setDelegate:self];
	[loader setModel:model];
	
	if([model loadLocalFile]) [loader loadFile:[model loadLocalFile]];
	else if([model loadRemoteURL]) [loader loadAdURL:[model loadRemoteURL]];
	else if(type == SMAdTypeTwixt && [model loadInterFCID]) [loader loadAdWithFCID:[model loadInterFCID]];
	else if([model loadFCID] && ![model loadPlacement] && ![model area]) [loader loadAdWithFCID:[model loadFCID]];
	else if([model loadFCID] && [model loadPlacement] && ![model area]) [loader loadAdWithFCID:[model loadFCID] andPlacementId:[model loadPlacement]];
	else if(type == SMAdTypeBanner && [model loadRemoteURLForBanner]) [loader loadAdURL:[model loadRemoteURLForBanner]];
	else if(type == SMAdTypeTwixt && [model loadRemoteURLForInterstitial]) [loader loadAdURL:[model loadRemoteURLForInterstitial]];
	else [loader load];
}

- (void) loaderDidComplete:(SMAdLoader *) _loader {
	//NSLog(@"loader did complete!");
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	
	//check for dealloc if needed
	_internal->loads--;
	if(_internal->shouldDealloc && _internal->loads == 0) {
		[self dealloc];
		return;
	}
	
	//clear loader's delegate
	[_loader setDelegate:nil];
	
	//setup ploader
	SMAdPrivateLoader * ploader = NULL;
	if(_loader == _internal->bannerLoader->loader) {
		ploader = _internal->bannerLoader;
	} else if(_loader == _internal->interstitialLoader->loader) {
		ploader = _internal->interstitialLoader;
	}
	
	//if went BG in the middle of a request.
	if(_internal->didGoBG) {
		//NSLog(@"did go BG!");
		_internal->didGoBG = FALSE;
		_internal->bannerWasInTakeover = false;
		_internal->requestedBanner = false;
		_internal->requestedInterstitial = false;
		[(SMAdIPrivate *)self resetPrivateLoader:ploader];
		return;
	}
	
	//setup vars
	SMAdType type = 0;
	SMAdModel * model = NULL;
	SMAdInspector * inspector = NULL;
	SMAdLoader * loader = _loader;
	if(loader == _internal->bannerLoader->loader) {
		type = SMAdTypeBanner;
		model = _internal->bannerLoader->model;
		inspector = _internal->bannerLoader->inspector;
		_internal->requestedBanner = FALSE;
	} else if(loader == _internal->interstitialLoader->loader) {
		ploader = _internal->interstitialLoader;
		type = SMAdTypeTwixt;
		model = _internal->interstitialLoader->model;
		inspector = _internal->interstitialLoader->inspector;
		_internal->requestedInterstitial = FALSE;
	}
	
	//set ad content on loader
	[inspector setAdcontent:[loader adcontent]];
	
	//make sure it's valid.
	if(![inspector isValid]) {
		[self _adNotAvailableForType:type];
		[(SMAdIPrivate *)self resetPrivateLoader:ploader];
		return;
	}
	
	//render house ad if required
	if([inspector isHouseAd]) {
		[(SMAdIPrivate *)self renderHouseAdWithInspector:inspector model:model loader:loader];
		[self _adNotAvailableForType:type];
		[(SMAdIPrivate *)self resetPrivateLoader:ploader];
		return;
	}
	
	//check for 3rd party
	Boolean is3RDParty = [inspector is3RDParty];
	
	//if the add is 3rd party, admeld, check that we're
	//in iphone. otherwise it's an invalid ad
	if(is3RDParty && [inspector isAdMeld] && [SMAdUtility isPad]) {
		[self _adNotAvailableForType:type];
		[(SMAdIPrivate *)self resetPrivateLoader:ploader];
		return;
	}
	
	//update the model with any 3rd party info
	if(is3RDParty && [inspector isAdMeld]) {
		[model setIsAdMeld:TRUE];
	}
	
	//check for initial validity. these don't require content to be ready.
	//if the ad is 3rd party ad, then we continue to load because there's
	//a custom renderer that will render the 3rd party ad.
	if(!is3RDParty && [inspector isNonMobileAd]) {
		if(ploader) {
			[ploader->errbeacon setModel:ploader->model];
			[ploader->errbeacon sendInit];
			[ploader->errbeacon sendEcho];
			[ploader->errbeacon sendNonMobile];
		}
		[self _adNotAvailableForType:type];
		[(SMAdIPrivate *)self resetPrivateLoader:ploader];
		return;
	}
	
	//have the inspector load the ad content
	NSURL * burl = [NSURL URLWithString:[loader adpath]];
	[inspector setBaseURL:burl];
	[inspector setDelegate:self];
	[inspector load];
}

- (void) adInspectorIsReady:(SMAdInspector *) _inspector {
	//NSLog(@"ad inspector ready!");
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	
	//clear inspector delegate
	[_inspector setDelegate:nil];
	
	//setup ploader
	SMAdPrivateLoader * ploader = NULL;
	if(_inspector == _internal->bannerLoader->inspector) {
		ploader = _internal->bannerLoader;
	} else if(_inspector == _internal->interstitialLoader->inspector) {
		ploader = _internal->interstitialLoader;
	}
	
	//if went BG in the middle of a request.
	if(_internal->didGoBG) {
		//NSLog(@"did go BG! 22");
		_internal->didGoBG = FALSE;
		_internal->bannerWasInTakeover = false;
		_internal->requestedBanner = false;
		_internal->requestedInterstitial = false;
		[(SMAdIPrivate *)self resetPrivateLoader:ploader];
		return;
	}
	
	//setup vars
	SMAdType type = 0;
	SMAdModel * model = NULL;
	SMAdInspector * inspector = _inspector;
	SMAdRendererBase <SMAdRenderer> * active = NULL;
	if(inspector == _internal->bannerLoader->inspector) {
		type = SMAdTypeBanner;
		model = _internal->bannerLoader->model;
		active = _internal->bannerLoader->active;
	} else if(inspector == _internal->interstitialLoader->inspector) {
		type = SMAdTypeTwixt;
		model = _internal->interstitialLoader->model;
	}
	
	//if it's a 3rd party ad, consider it available
	if([inspector is3RDParty]) {
		if(type == SMAdTypeBanner && _delegate && \
		   [_delegate respondsToSelector:@selector(smAdBannerAvailable:withBannerView:)])
		{
			[(SMAdIPrivate *)self renderAdWithBannerView];
		} else {
			[self _adAvailableForType:type];
		}
		return;
	}
	
	//update the product family
	if(type == SMAdTypeBanner) [model setPfam:@"display"];
	else [model setPfam:@"interstitial"];
	
	//make sure the render version of the template is not greater than the sdk
	//version. if it's greater than the sdk version there's no way the sdk can
	//render it.
	int renderVersion = [[inspector renderVersion] intValue];
	if(renderVersion > SMAdBeaconVersion) {
		[self _adNotAvailableForType:type];
		[(SMAdIPrivate *)self resetPrivateLoader:ploader];
		return;
	}
	
	//check for device mismatch
	if([inspector deviceMismatch]) {
		if(ploader) {
			[ploader->errbeacon setModel:ploader->model];
			[ploader->errbeacon sendInit];
			[ploader->errbeacon sendEcho];
			[ploader->errbeacon sendDeviceMismatch];
		}
		[self _adNotAvailableForType:type];
		[(SMAdIPrivate *)self resetPrivateLoader:ploader];
		return;
	}
	
	//make sure ad is a banner ad if requested that type
	if(type == SMAdTypeBanner && ![inspector isOldCreative] && \
	   ![[inspector adType] isEqualToString:@"banner"])
	{
		if(ploader) {
			[ploader->errbeacon setModel:ploader->model];
			[ploader->errbeacon sendInit];
			[ploader->errbeacon sendEcho];
			[ploader->errbeacon sendIntegrationMismatch];
		}
		[self _adNotAvailableForType:type];
		[(SMAdIPrivate *)self resetPrivateLoader:ploader];
		return;
	}
	
	//make sure ad is an interstitial if requested that type
	if(type == SMAdTypeTwixt && ![inspector isOldCreative] && \
	   ![[inspector adType] isEqualToString:@"interstitial"])
	{
		if(ploader) {
			[ploader->errbeacon setModel:ploader->model];
			[ploader->errbeacon sendInit];
			[ploader->errbeacon sendEcho];
			[ploader->errbeacon sendIntegrationMismatch];
		}
		[self _adNotAvailableForType:type];
		[(SMAdIPrivate *)self resetPrivateLoader:ploader];
		return;
	}
	
	//check if banner type and if already in a takeover. if we're
	//already in a takeover, we don't want to tell the delegate we have
	//a banner otherwise it will close the current takeover.
	if(type == SMAdTypeBanner && [active isInTakeover]) {
		if(_internal->autoUpdater && _internal->autoUpdateInviteView) {
			[_internal->autoUpdater stop];
		}
		_internal->bannerWasInTakeover = true;
		return;
	}
	
	//check if interstitial type and banner is in takeover. if so we don't
	//want to tell the delegate an interstitial is available. otherwise
	//they may show the interstitial over the banner takeover. so set a flag
	//and wait till the next request for an interstitial comtes in.
	if(type == SMAdTypeTwixt && _internal->bannerLoader->active && \
	   [_internal->bannerLoader->active isInTakeover])
	{
		[self _adNotAvailableForType:SMAdTypeTwixt];
		return;
	}
	
	//check for auto updater
	if(type == SMAdTypeBanner && _internal->autoUpdater && _internal->autoUpdateInviteView) {
		[self displayBannerInView:_internal->autoUpdateInviteView];
		[_internal->autoUpdater start];
		return;
	}
	
	//render with a banner view, or just tell the delegate an ad is available
	if(type == SMAdTypeBanner && _delegate && \
	   [_delegate respondsToSelector:@selector(smAdBannerAvailable:withBannerView:)])
	{
		[(SMAdIPrivate *)self renderAdWithBannerView];
	} else {
		[self _adAvailableForType:type];
	}
}

- (void) displayInView:(UIView *) view {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	
	//check for banner loader validity
	if(!_internal->bannerLoader || !_internal->bannerLoader->loader) {
		[self failWithError:_SMAdErrorAdNotAvailable];
		[self _adNotAvailableForType:SMAdTypeBanner];
		return;
	}
	
	//setup vars
	SMAdRendererBase <SMAdRenderer> * renderer = NULL;
	SMAdRendererBase <SMAdRenderer> * active = _internal->bannerLoader->active;
	SMAdModel * model = _internal->bannerLoader->model;
	SMAdLoader * loader = _internal->bannerLoader->loader;
	SMAdInspector * inspector = _internal->bannerLoader->inspector;
	
	//create new renderer
	Class rc = [SMAdRendererHelper \
		getRendererFromInspector:inspector model:model type:SMAdTypeBanner];
	if(!rc) {
		[(SMAdIPrivate *)self resetPrivateLoader:_internal->bannerLoader];
		[self _adNotAvailableForType:SMAdTypeBanner];
		return;
	}
	renderer = [[rc alloc] init];
	[renderer setOrientation:_internal->orientation updateFrames:false];
	[renderer setAd:self];
	[renderer setInspector:inspector];
	[renderer setModel:model];
	[renderer setLoader:loader];
	[renderer setAdDelegate:_delegate];
	[renderer setView:view];
	
	//update active
	//teardown active renderer
	if(active) {
		[active teardown];
		[active release];
		active = NULL;
	}
	_internal->bannerLoader->active = [renderer retain];
	[renderer release];
	
	//cleanup vars on private loader
	[(SMAdIPrivate *)self resetPrivateLoader:_internal->bannerLoader];
	
	//render new ad
	[renderer render];
}

- (void) renderHouseAdWithInspector:(SMAdInspector *) inspector model:(SMAdModel *) model loader:(SMAdLoader *) loader {
	//vars
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	SMAdRendererBase <SMAdRenderer> * renderer = NULL;
	SMAdRendererBase <SMAdRenderer> * active = _internal->houseLoader->active;
	
	//teardown active
	if(active) {
		[active teardown];
		[active release];
		_internal->houseLoader->active = NULL;
		active = NULL;
	}
	
	//get new renderer
	Class rc = [SMAdRendererHelper \
		getRendererFromInspector:inspector model:model type:SMAdTypeHouse];
	if(!rc) {
		[(SMAdIPrivate *)self resetPrivateLoader:_internal->houseLoader];
		return;
	}
	renderer = [[rc alloc] init];
	[renderer setOrientation:_internal->orientation updateFrames:false];
	[renderer setAd:self];
	[renderer setInspector:inspector];
	[renderer setModel:model];
	[renderer setLoader:loader];
	[renderer setAdDelegate:_delegate];
	
	//set active
	_internal->houseLoader->active = [renderer retain];
	[renderer release];
	
	//renderer has control, clear internal structure
	[(SMAdIPrivate *)self resetPrivateLoader:_internal->houseLoader];
	
	//render
	[renderer render];
}

- (void) renderAdWithBannerView {
	//vars
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	SMAdBannerView * bview = NULL;
	SMAdRendererBase <SMAdRenderer> * renderer = NULL;
	SMAdRendererBase <SMAdRenderer> * active = _internal->bannerLoader->active;
	SMAdModel * model = _internal->bannerLoader->model;
	SMAdLoader * loader = _internal->bannerLoader->loader;
	SMAdInspector * inspector = _internal->bannerLoader->inspector;
	
	//check delegate
	if(!_delegate || ![_delegate respondsToSelector:@selector(smAdBannerAvailable:withBannerView:)]) {
		return;
	}
	
	//release any previous banner view
	if(_internal->bannerView) {
		[_internal->bannerView removeFromSuperview];
		[_internal->bannerView release];
		_internal->bannerView = NULL;
	}
	
	//remove and clean active renderer
	if(active) {
		[active teardown];
		[active release];
		active = NULL;
	}
	
	//get new renderer
	Class rc = [SMAdRendererHelper \
		getRendererFromInspector:inspector model:model type:SMAdTypeBanner];
	if(!rc) {
		[(SMAdIPrivate *)self resetPrivateLoader:_internal->bannerLoader];
		[self _adNotAvailableForType:SMAdTypeBanner];
		return;
	}
	bview = [[SMAdBannerView alloc] _initWithFrame:CGRectMake(0,0,1,1)];
	renderer = [[rc alloc] init];
	_internal->bannerView = [bview retain];
	_internal->bannerLoader->active = [renderer retain];
	[bview release];
	[(SMAdBannerViewPrivate *)bview setRenderer:renderer];
	[renderer release];
	[renderer setOrientation:_internal->orientation updateFrames:false];
	[renderer setAd:self];
	[renderer setInspector:inspector];
	[renderer setModel:model];
	[renderer setLoader:loader];
	[renderer setAdDelegate:_delegate];
	[renderer setView:bview];
	[(SMAdBannerViewPrivate *)bview setOrientation:_internal->orientation];
	[(SMAdBannerViewPrivate *)bview _updateFrame];
	
	//renderer has control, clear internal structure
	[(SMAdIPrivate *)self resetPrivateLoader:_internal->bannerLoader];
	
	//pass of view to delegate
	[_delegate smAdBannerAvailable:self withBannerView:bview];
}

- (void) displayBannerInView:(UIView *) view {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(_internal->isSMIntegrationDisabled) return;
	[self displayInView:view];
}

- (void) displayInterstitial {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	
	//check for banner loader validity
	if(!_internal->interstitialLoader || !_internal->interstitialLoader->loader) {
		[self failWithError:_SMAdErrorAdNotAvailable];
		[self _adNotAvailableForType:SMAdTypeTwixt];
		return;
	}
	
	//setup vars
	SMAdRendererBase <SMAdRenderer> * renderer = NULL;
	SMAdRendererBase <SMAdRenderer> * active = _internal->interstitialLoader->active;
	SMAdModel * model = _internal->interstitialLoader->model;
	SMAdLoader * loader = _internal->interstitialLoader->loader;
	SMAdInspector * inspector = _internal->interstitialLoader->inspector;
	
	//create new renderer
	Class rc = [SMAdRendererHelper \
		getRendererFromInspector:inspector model:model type:SMAdTypeTwixt];
	if(!rc) {
		[self _adNotAvailableForType:SMAdTypeTwixt];
		[(SMAdIPrivate *)self resetPrivateLoader:_internal->interstitialLoader];
		return;
	}
	renderer = [[rc alloc] init];
	[renderer setOrientation:_internal->orientation updateFrames:false];
	[renderer setAd:self];
	[renderer setInspector:inspector];
	[renderer setModel:model];
	[renderer setLoader:loader];
	[renderer setAdDelegate:_delegate];
	
	//update active
	_internal->interstitialLoader->active = [renderer retain];
	[renderer release];
	
	//cleanup vars on private loader
	[_internal->interstitialLoader->model release];
	[_internal->interstitialLoader->loader release];
	[_internal->interstitialLoader->inspector release];
	_internal->interstitialLoader->model = NULL;
	_internal->interstitialLoader->loader = NULL;
	_internal->interstitialLoader->inspector = NULL;
	
	//teardown active renderer
	[active teardown];
	[active release];
	active = NULL;
	
	//render new ad
	[renderer render];
}

- (void) loaderDidFail:(SMAdLoader *) loader error:(_SMAdError) error {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	[loader setDelegate:nil];
	if(loader == _internal->bannerLoader->loader) {
		_internal->requestedBanner = FALSE;
		[(SMAdIPrivate *)self resetPrivateLoader:_internal->bannerLoader];
	} else if(loader == _internal->interstitialLoader->loader) {
		_internal->requestedInterstitial = FALSE;
		[(SMAdIPrivate *)self resetPrivateLoader:_internal->interstitialLoader];
	}
	[self failWithError:error];
	_internal->loads--;
	if(_internal->shouldDealloc && _internal->loads == 0) {
		[self dealloc];
		return;
	}
	if(_internal->autoUpdater) [_internal->autoUpdater start];
}

- (void) hideBannerTakeover {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(_internal->bannerLoader->active) [_internal->bannerLoader->active hideModals];
}

- (void) hideInterstitial {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(_internal->interstitialLoader->active) [_internal->interstitialLoader->active hideModals];
}

- (void) setConfig:(NSMutableDictionary *) config {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(_internal->config) [_internal->config release];
	_internal->config = [config retain];
	if(_internal->bannerLoader && _internal->bannerLoader->model) {
		[_internal->bannerLoader->model updateFromConfig:config];
	}
	if(_internal->interstitialLoader && _internal->interstitialLoader->model) {
		[_internal->interstitialLoader->model updateFromConfig:config];
	}
}

- (void) setOrientation:(UIDeviceOrientation) orientation {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	_internal->orientation = orientation;
	if(_internal->bannerView) [(SMAdBannerViewPrivate *)_internal->bannerView setOrientation:orientation];
	if(_internal->bannerLoader->active) [_internal->bannerLoader->active setOrientation:orientation updateFrames:true];
	if(_internal->interstitialLoader->active) [_internal->interstitialLoader->active setOrientation:orientation updateFrames:true];
}

- (Boolean) supportsOrientation:(UIDeviceOrientation) orientation {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(_internal->interstitialLoader->active && [_internal->interstitialLoader->active isVisible]) {
		return [_internal->interstitialLoader->active supportsOrientation:orientation];
	} else if(_internal->bannerLoader->active && [_internal->bannerLoader->active isVisible]) {
		return [_internal->bannerLoader->active supportsOrientation:orientation];
	}
	return false;
}

- (void) startAutoUpdateBannerAdsInView:(UIView *) view {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	SMAd <SMAdAutoDelegate> * _self = self;
	Boolean requestBanner = true;
	if(_internal->bannerWasInTakeover) {
		[(SMAdIPrivate *)self showLateBanner];
		requestBanner = false;
	}
	if(_internal->autoUpdater) {
		if(_internal->autoUpdateInviteView != view) {
			[_internal->autoUpdateInviteView release];
			_internal->autoUpdateInviteView = [view retain];
		}
		[_internal->autoUpdater stop];
		[_internal->autoUpdater start];
		return;
	}
	if(!_internal->autoUpdater) _internal->autoUpdater = [[SMAdAuto alloc] init];
	[_internal->autoUpdater setDelegate:_self];
	[_internal->autoUpdater setTickTime:_internal->autoUpdateInterval];
	if(_internal->autoUpdateInviteView) [_internal->autoUpdateInviteView release];
	_internal->autoUpdateInviteView = [view retain];
	if(requestBanner) [self __requestBanner];
}

- (void) restartAutoUpdating {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	//NSLog(@"%@",_internal->autoUpdateInviteView);
	if(!_internal->autoUpdateInviteView) {
		//NSLog(@"no view!");
		return;
	}
	if(_internal->bannerWasInTakeover) {
		//NSLog(@"banner was in takeover!");
		[(SMAdIPrivate *)self showLateBanner];
		return;
	}
	[_internal->autoUpdater start];
}

- (void) showLateBanner {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	_internal->bannerWasInTakeover = false;
	[NSTimer scheduledTimerWithTimeInterval:_internal->animationDuration+.2 \
		target:self selector:@selector(finallyShowLateBanner)
		userInfo:nil repeats:false];
}

- (void) finallyShowLateBanner {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	[self displayBannerInView:_internal->autoUpdateInviteView];
	if(_internal->autoUpdater) [_internal->autoUpdater start];
}

- (void) stopAutoUpdateBannerAds {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	[_internal->autoUpdater stop];
	[_internal->autoUpdater release];
	[_internal->autoUpdateInviteView release];
	_internal->autoUpdateInviteView = NULL;
	_internal->autoUpdater = NULL;
}

- (void) pauseAutoUpdateBannerAds {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	[_internal->autoUpdater stop];
}

- (void) autoDidTick:(SMAdAuto *) autob {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	//NSLog(@"tick!");
	[_internal->autoUpdater stop];
	if(_internal->bannerWasInTakeover) {
		//NSLog(@"was in takeover!");
		[self showLateBanner];
		return;
	}
	[self __requestBanner];
}

- (void) loaderDidStartADPRequest:(SMAdLoader *) loader {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(loader == _internal->bannerLoader->loader) [_internal->bannerLoader->model recordADPStart];
	if(loader == _internal->interstitialLoader->loader) [_internal->interstitialLoader->model recordADPStart];
}

- (void) loaderDidStartADRequest:(SMAdLoader *) loader {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(loader == _internal->bannerLoader->loader) [_internal->bannerLoader->model recordADStart];
	if(loader == _internal->interstitialLoader->loader) [_internal->interstitialLoader->model recordADStart];
}

- (void) loaderDidFinishADPRequest:(SMAdLoader *) loader {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(loader == _internal->bannerLoader->loader) [_internal->bannerLoader->model recordADPEnd];
	if(loader == _internal->interstitialLoader->loader) [_internal->interstitialLoader->model recordADPEnd];
}

- (void) loaderDidFinishADRequest:(SMAdLoader *) loader {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(loader == _internal->bannerLoader->loader) {
		[_internal->bannerLoader->model recordADEnd];
		[_internal->bannerLoader->model setBurl:[loader adpath]];
	}
	if(loader == _internal->interstitialLoader->loader) {
		[_internal->interstitialLoader->model recordADEnd];
		[_internal->interstitialLoader->model setBurl:[loader adpath]];
	}
}

- (void) setAutoUpdateInterval:(NSTimeInterval) interval {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(interval < 10) return;
	_internal->autoUpdateInterval = interval;
}

- (void) setDefaultAnimationDuration:(NSTimeInterval) duration {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(duration < .05 || duration > 2) return;
	_internal->animationDuration = duration;
}

- (NSTimeInterval) defaultAnimationDuration {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	return _internal->animationDuration;
}

- (Boolean) inviteSupportsOrientation:(UIDeviceOrientation) orientation {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(!_internal->bannerLoader->active) return false;
	return [_internal->bannerLoader->active supportsOrientation:orientation];
}

- (Boolean) interstitialSupportsOrientation:(UIDeviceOrientation) orientation {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(!_internal->interstitialLoader->active) return false;
	return [_internal->interstitialLoader->active supportsOrientation:orientation];
}

- (Boolean) interstitialAvailable {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(_internal->requestedInterstitial) return FALSE;
	return (_internal->interstitialLoader && _internal->interstitialLoader->loader);
}

- (Boolean) bannerAvailable {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	return (_internal->bannerLoader && _internal->bannerLoader->loader);
}

- (void) appBackground {
	//NSLog(@"app background!");
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	_internal->didGoBG = TRUE;
	if([_internal->autoUpdater isRunning]) {
		//NSLog(@"should resume!");
		[self pauseAutoUpdateBannerAds];
		_internal->resumeAutoFromAppBG = TRUE;
	}
	if(_internal->bannerLoader->active) [_internal->bannerLoader->active appBackground];
	if(_internal->interstitialLoader->active) [_internal->interstitialLoader->active appBackground];
}

- (void) appForeground {
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	//NSLog(@"foreground!");
	if(_internal->resumeAutoFromAppBG) {
		//NSLog(@"resume!");
		[self restartAutoUpdating];
	}
	if(_internal->bannerWasInTakeover && !_internal->bannerLoader->loader) {
		//NSLog(@"HERE!");
		//_internal->bannerWasInTakeover = false;
	}
	//_internal->didGoBG = FALSE;
	if(_internal->bannerLoader->active) [_internal->bannerLoader->active appForeground];
	if(_internal->interstitialLoader->active) [_internal->interstitialLoader->active appForeground];
}

- (void) registerForAppStateChanges {
	NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(appBackground)
		name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
	[center addObserver:self selector:@selector(appForeground)
		name:@"UIApplicationDidBecomeActiveNotification" object:nil];
}

- (void) resetPrivateLoader:(SMAdPrivateLoader *) loader {
	[loader->model release];
	[loader->loader release];
	[loader->inspector release];
	loader->loader = NULL;
	loader->model = NULL;
	loader->inspector = NULL;
}

- (void) perror:(_SMAdError) error {
	if(error == _SMAdErrorConfigNotSet) {
		NSLog(@"SMAdError: SMAdErrorConfigNotSet - The config property is not "
			"set on the SMAd instance.");
	}
	if(error == _SMAdErrorNetworkError) {
		NSLog(@"SMAdError: SMAdErrorNetworkError - A network error occured.");
	}
	if(error == _SMAdErrorInternalError) {
		NSLog(@"SMAdError: SMAdErrorInternalError - An internal framework "
			"error occured.");
	}
	if(error == _SMAdErrorAdNotAvailable) {
		NSLog(@"SMAdError: SMAdErrorAdNotAvailable - An ad was not available, "
			"an internal house ad was served.");
	}
	
	if(error == _SMAdErrorLocalFileNotFound) {
		NSLog(@"SMAdError: SMAdErrorLocalFileNotFound - Trying to load a "
			"local ad failed because the file is missing.");
	}
	if(error == _SMAdErrorInvalidFCID) {
		NSLog(@"SMAdError: SMAdErrorInvalidFCID - The FCID you're trying to "
			"load is not formatted correctly. It should contain a dash (1234-1).");
	}
}

- (NSString *) serror:(_SMAdError) error {
	if(error == _SMAdErrorConfigNotSet) {
		return @"SMAdError: SMAdErrorConfigNotSet - The config property "
		"is not set on the SMAd instance.";
	}
	if(error == _SMAdErrorNetworkError) {
		return @"SMAdError: SMAdErrorNetworkError - A network error occured.";
	}
	if(error == _SMAdErrorInternalError) {
		return @"SMAdError: SMAdErrorInternalError - An internal framework "
		"error occured.";
	}
	if(error == _SMAdErrorAdNotAvailable) {
		return @"SMAdError: SMAdErrorAdNotAvailable - An ad was not "
		"available, an internal house ad was served.";
	}
	if(error == _SMAdErrorLocalFileNotFound) {
		return @"SMAdError: SMAdErrorLocalFileNotFound - Trying to load "
		"a local ad failed because the file is missing.";
	}
	if(error == _SMAdErrorInvalidFCID) {
		return @"SMAdError: SMAdErrorInvalidFCID - The FCID you're trying to "
		"load is not formatted correctly. It should contain a dash (1234-1).";
	}
	return NULL;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAd");
	#endif
	NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
	[center removeObserver:self name:@"UIApplicationDidBecomeActiveNotification" object:nil];
	[self stopAutoUpdateBannerAds];
	SMAdPrivate * _internal = (SMAdPrivate *)internal;
	if(_internal->loads > 0) {
		_internal->shouldDealloc = true;
		return;
	}
	if(_internal->bannerView) {
		[_internal->bannerView removeFromSuperview];
		[_internal->bannerView release];
	}
	if(_internal->bannerLoader) {
		if(_internal->bannerLoader->active) {
			[_internal->bannerLoader->active teardown];
			[_internal->bannerLoader->active release];
		}
		[self resetPrivateLoader:_internal->bannerLoader];
		[_internal->bannerLoader->errbeacon release];
		_internal->bannerLoader->errbeacon = NULL;
	}
	if(_internal->interstitialLoader) {
		if(_internal->interstitialLoader->active) {
			[_internal->interstitialLoader->active teardown];
			[_internal->interstitialLoader->active release];
		}
		[self resetPrivateLoader:_internal->interstitialLoader];
		[_internal->interstitialLoader->errbeacon release];
		_internal->interstitialLoader->errbeacon = NULL;
	}
	if(_internal->houseLoader) {
		if(_internal->houseLoader->active) [_internal->houseLoader->active teardown];
		[self resetPrivateLoader:_internal->houseLoader];
	}
	if(_internal->initBeacon) [_internal->initBeacon release];
	if(_internal->autoUpdater) [_internal->autoUpdater release];
	if(_internal->config) [_internal->config release];
	if(_internal->autoUpdateInviteView) [_internal->autoUpdateInviteView release];
	_internal->autoUpdateInterval = 0;
	_internal->autoUpdateInviteView = NULL;
	_internal->config = NULL;
	_internal->bannerView = NULL;
	free(_internal->bannerLoader);
	free(_internal->interstitialLoader);
	free(_internal->houseLoader);
	free(internal);
	[super dealloc];
}

@end
