
#import "SMAdUtility.h"

bool accelerometerIsShaking(UIAcceleration * last, UIAcceleration * current, double threshold) {
	double deltaX = fabs(last.x - current.x);
	double deltaY = fabs(last.y - current.y);
	double deltaZ = fabs(last.z - current.z);
	return
	(deltaX > threshold && deltaY > threshold) ||
	(deltaX > threshold && deltaZ > threshold) ||
	(deltaY > threshold && deltaZ > threshold);
}

@implementation SMAdUtility

+ (BOOL) isPad {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if([SMAdUtility iOSVersion] < 3.2) {
		return false;
	}
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
	return false;
}

+ (float) iOSVersion {
	return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (NSString *) urlencodeString:(NSString *) str {
	return [(NSString *)
	CFURLCreateStringByAddingPercentEscapes(
	NULL,(CFStringRef)str,NULL,
	(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
	kCFStringEncodingUTF8) autorelease];
}

@end
