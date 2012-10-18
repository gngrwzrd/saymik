
#import "SMAdRendererHelper.h"

@implementation SMAdRendererHelper

+ (Class) getRendererFromInspector:(SMAdInspector *) inspector model:(SMAdModel *) model type:(SMAdType) type {
	//vars
	Class render_class = NULL;	
	Boolean isphone = ![SMAdUtility isPad];
	
	//check for house ad
	if([inspector isHouseAd]) {
		render_class = [SMAdHouseRenderer class];
		goto return_class;
	}
	
	//check for 3RD parties
	if([inspector isAdMeld]) {
		render_class = [SMAdRendererAdMeld class];
		goto return_class;
	}
	
	//mobile ad builder version
	NSString * mab_version = [inspector MABVersion];
	Boolean isold = !([mab_version rangeOfString:@"."].location == NSNotFound);
	
	//check for non-phone device and old creative. they don't mix.
	if(!isphone && isold) return NULL;
	
	//check for old creative from mobile ad builder.
	if(isold) {
		if(type == SMAdTypeBanner) {
			render_class = [SMAdBannerRendererV1 class];
			goto return_class;
		} else {
			render_class = [SMAdInterstitialRendererV1 class];
			goto return_class;
		}
	}
	
	//grab the render version
	NSString * render_version = [inspector renderVersion];
	NSInteger i_render_version = [render_version intValue];
	
	//check for revision number
	if(type == SMAdTypeBanner) {
		if(i_render_version == 2) {
			if([inspector requiresTwoWebViews]) render_class = [SMAdBannerRendererV2_2WebViews class];
			else render_class = [SMAdBannerRendererV2 class];
		}
	} else if(type == SMAdTypeTwixt) {
		if(i_render_version == 2) {
			render_class = [SMAdInterstitialRendererV2 class];
		}
	}
	
	return_class:
	return render_class;
}

@end
