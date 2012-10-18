
#import "SMAdActionSaveImage.h"

@implementation SMAdActionSaveImage

- (void) execute {
	NSString * fileurl = [_message objectForKey:@"img"];
	if(!fileurl) fileurl = [_message objectForKey:@"url"];
	if(!fileurl) fileurl = [_message objectForKey:@"path"];
	if(!fileurl) fileurl = [_message objectForKey:@"href"];
	if(!fileurl) fileurl = [_message objectForKey:@"location"];
	if(!fileurl) {
		[self finish];
		return;
	}
	NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileurl]];
	UIImage * img = [UIImage imageWithData:data];
	UIImageWriteToSavedPhotosAlbum(img,nil,nil,nil);
	[self finish];
}

- (BOOL) returnForUIWebView {
	return FALSE;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionSaveImage");
	#endif
	[super dealloc];
}

@end
