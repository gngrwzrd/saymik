
#import "UIView+Additions.h"

@implementation UIView (Additions)

- (BOOL) findAndResignFirstResonder {
	if([self isFirstResponder]) {
		[self resignFirstResponder];
		return YES;     
    }
	UIView * subView;
	for(subView in [self subviews]) {
		if([subView findAndResignFirstResonder]) return YES;
    }
	return NO;
}

@end
