
#import "VEActionSaveImage.h"

@implementation VEActionSaveImage

- (void) execute {
	NSURL * url = [_request URL];
	NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSArray * values = [query componentsSeparatedByString:@"|"];
	NSString * fileurl = [values objectAtIndex:0];
	NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileurl]];
	UIImage * img = [UIImage imageWithData:data];
	UIImageWriteToSavedPhotosAlbum(img,nil,nil,nil);
	[self finish];
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: VEActionSaveImage");
	#endif
	[super dealloc];
}

@end
