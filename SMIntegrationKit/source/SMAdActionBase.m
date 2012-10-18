
#import "SMAdActionBase.h"
#import "SMAdRendererBase.h"

@implementation SMAdActionBase
@synthesize message = _message;
@synthesize request = _request;
@synthesize selcontext = _selcontext;
@synthesize renderer = _renderer;
@synthesize delegate = _delegate;
@synthesize webview = _webview;
@synthesize viewController = _viewController;
@synthesize model = _model;

- (void) execute {
	NSLog(@"empty execute method in action: %@",[self class]);
}

- (BOOL) returnForUIWebView {
	return YES;
}

- (BOOL) requiresPersistence {
	return YES;
}

- (void) finish {
	if([_message objectForKey:@"callback"]) {
		NSString * func = [_message objectForKey:@"callback"];
		NSString * func_wp = [func stringByAppendingString:@"();"];
		[_webview stringByEvaluatingJavaScriptFromString:func_wp];
	}
	if([_message objectForKey:@"callbackAction"]) {
		NSString * ac = [_message objectForKey:@"callbackAction"];
		NSString * action = [NSString stringWithFormat:@"processActionsForId('%@')",ac];
		[_webview stringByEvaluatingJavaScriptFromString:action];
	}
	if(_delegate && [_delegate respondsToSelector:@selector(actionDidFinish:)]) {
		[_delegate actionDidFinish:self];
	}
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionBase");
	#endif
	[self setRequest:nil];
	[self setMessage:nil];
	_viewController = nil;
	_webview = NULL;
	_renderer = NULL;
	_delegate = NULL;
	_selcontext = NULL;
	_model = NULL;
	[super dealloc];
}

@end
