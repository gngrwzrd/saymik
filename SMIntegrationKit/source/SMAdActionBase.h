
#import <Foundation/Foundation.h>
#import "SMAdAction.h"
#import "SMAdRenderer.h"
#import "SMAdActionDelegate.h"
#import "SMAdModel.h"

@class SMAdRendererBase;

@interface SMAdActionBase : NSObject <SMAdAction> {
	NSURLRequest * _request;
	NSDictionary * _message;
	UIWebView * _webview;
	UIViewController * _viewController;
	NSObject <SMAdActionDelegate> * _delegate;
	SMAdRendererBase * _selcontext;
	SMAdRendererBase * _renderer;
	SMAdModel * _model;
}

@property (nonatomic,retain) NSURLRequest * request;
@property (nonatomic,retain) NSDictionary * message;
@property (nonatomic,assign) UIWebView * webview;
@property (nonatomic,assign) UIViewController * viewController;
@property (nonatomic,assign) SMAdRendererBase * renderer;
@property (nonatomic,assign) NSObject <SMAdActionDelegate> * delegate;
@property (nonatomic,assign) SMAdRendererBase * selcontext;
@property (nonatomic,assign) SMAdModel * model;

- (void) finish;
- (void) execute;
- (BOOL) returnForUIWebView;
- (BOOL) requiresPersistence;

@end
