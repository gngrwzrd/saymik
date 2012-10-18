
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMAdRendererBase.h"
#import "SMAdBeacon.h"
#import "SMAdUtility.h"
#import "defs.h"

@interface SMAdRendererAdMeld : SMAdRendererBase <UIWebViewDelegate> {
	UIDeviceOrientation _orientation;
	Boolean isportrait;
	UIWebView * _webview;
	SMAdBeacon * _engageBeacon;
}

- (Boolean) isVisible;

@end
