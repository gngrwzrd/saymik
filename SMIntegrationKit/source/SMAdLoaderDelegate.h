
@class SMAdLoader;

@protocol SMAdLoaderDelegate

- (void) loaderDidComplete:(SMAdLoader *) loader;
- (void) loaderDidFail:(SMAdLoader *) loader;
- (void) loaderDidFail:(SMAdLoader *) loader error:(int) error;
- (void) loaderDidStartADPRequest:(SMAdLoader *) loader;
- (void) loaderDidStartADRequest:(SMAdLoader *) loader;
- (void) loaderDidFinishADPRequest:(SMAdLoader *) loader;
- (void) loaderDidFinishADRequest:(SMAdLoader *) loader;

@end

