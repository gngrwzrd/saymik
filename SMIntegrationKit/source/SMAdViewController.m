
#import "SMAdViewController.h"

@implementation SMAdViewController

//- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation {
//	return TRUE;
//}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self performSelector:@selector(fixStatusBar) withObject:nil afterDelay:0];
}

- (void) fixStatusBar {
	[[UIApplication sharedApplication] setStatusBarOrientation:[self interfaceOrientation] animated:NO];
}

- (void)dealloc {
    [super dealloc];
}


@end
