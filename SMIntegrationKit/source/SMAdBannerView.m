
#include <stdbool.h>
#import "SMAdBannerView.h"
#import "SMAdRenderer.h"
#import "SMAdRendererBase.h"
#import "SMAdBannerViewInternal.h"
#import "defs.h"

static bool allowInit = false;

@implementation SMAdBannerView

- (id) init {
	if(!allowInit) {
		NSLog(@"You cannot instantiate an SMAdBannerView.");
		abort();
	}
	return nil;
}

- (id) initWithFrame:(CGRect)frame {
	if(!allowInit) {
		NSLog(@"You cannot instantiate an SMAdBannerView.");
		abort();
	}
	return nil;
}

- (id) initWithCoder:(NSCoder *) aDecoder {
	if(!allowInit) {
		NSLog(@"You cannot instantiate an SMAdBannerView.");
		abort();
	}
	return nil;
}

- (id) _initWithFrame:(CGRect) frame {
	allowInit = true;
	if(!(self = [super initWithFrame:frame])) return nil;
	_internal = calloc(1,sizeof(SMAdBannerViewInternal));
	allowInit = false;
	return self;
}

- (void) _updateFrame {
	SMAdBannerViewInternal * internal = (SMAdBannerViewInternal *)_internal;
	Boolean isphone = ![SMAdUtility isPad];
	Boolean isportrait = UIDeviceOrientationIsPortrait(internal->orientation);
	CGRect frame = {0};
	if(isportrait && isphone) frame = CGRectMake(0,0,320,50);
	if(!isportrait && isphone) frame = CGRectMake(0,0,480,32);
	if(isportrait && !isphone) frame = CGRectMake(0,0,768,66);
	if(!isportrait && !isphone) frame = CGRectMake(0,0,1024,66);
	[self setFrame:frame];
}

- (void) willMoveToSuperview:(UIView *) newSuperview {
	if(!newSuperview) return;
	SMAdBannerViewInternal * internal = (SMAdBannerViewInternal *)_internal;
	[internal->renderer render];
}

- (void) setRenderer:(SMAdRendererBase <SMAdRenderer>*) renderer {
	SMAdBannerViewInternal * internal = (SMAdBannerViewInternal *)_internal;
	internal->renderer = [renderer retain];
}

- (void) setOrientation:(UIDeviceOrientation) orientation {
	SMAdBannerViewInternal * internal = (SMAdBannerViewInternal *)_internal;
	internal->orientation = orientation;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdBannerView");
	#endif
	SMAdBannerViewInternal * internal = (SMAdBannerViewInternal *)_internal;
	[internal->renderer teardown];
	[internal->renderer release];
	free(_internal);
	[super dealloc];
}

@end
