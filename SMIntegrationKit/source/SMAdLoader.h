
#include <regex.h>
#import <Foundation/Foundation.h>
#import "SMAdLoaderDelegate.h"
#import "SMAdError.h"
#import "SMAdModel.h"

/**
 * The SMAdLoader class simplifies and segregates ad loading logic
 * into one class.
 */
@interface SMAdLoader : NSObject {
	Boolean err;
	NSObject <SMAdLoaderDelegate> * _delegate;
	NSDictionary * _adpcontent;
	NSString * _adpath;
	NSString * _adpurl;
	NSMutableData * adpdata;
	NSMutableData * addata;
	NSURLConnection * adpconn;
	NSURLConnection * adconn;
	SMAdModel * _model;
}

@property (nonatomic,assign) id delegate;
@property (nonatomic,assign) SMAdModel * model;
@property (nonatomic,copy) NSString * adpath;
@property (nonatomic,copy) NSString * adpurl;
@property (nonatomic,copy) NSDictionary * adpcontent;

- (void) appBackground;
- (void) load;
- (void) loadFile:(NSString *) adfile;
- (void) loadAdURL:(NSString *) adurl;
- (void) loadAdWithFCID:(NSString *) fcid;
- (void) loadAdWithFCID:(NSString *) fcid andPlacementId:(NSString *) placement;
- (void) parseADPResponse;
- (void) finished;
- (void) cancel;
- (void) fail;
- (void) failWithError:(_SMAdError) error;
- (Boolean) isLoading;
- (NSString *) adcontent;
- (NSDictionary *) adpcontent;

@end
