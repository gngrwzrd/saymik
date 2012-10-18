
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JSON.h"
#import "SMAdAction.h"
#import "SMAdActionLaunchURL.h"
#import "SMAdActionEmail.h"
#import "SMAdActionPrintf.h"
#import "SMAdActionMethodCall.h"
#import "SMAdActionSMS.h"
#import "SMAdActionSaveImage.h"
#import "SMAdActionPhone.h"
#import "SMAdActionSaveContact.h"
#import "SMAdRenderer.h"
#import "VEActionVideo.h"
#import "VEActionSaveImage.h"
#import "VEActionAlert.h"
#import "VEActionURL.h"
#import "VEActionSaveContact.h"
#import "VEActionEmail.h"
#import "VEActionSMS.h"
#import "VEActionClose.h"
#import "SMAdActionClose.h"
#import "SMAdActionVideo.h"
#import "SMAdActionShowTakeover.h"
#import "SMAdActionPrompt.h"
#import "SMAdActionAlert.h"
#import "SMAdActionTPB.h"

@interface SMActionHandler : NSObject {
	
}

+ (SMAdActionBase *)
createActionWithRenderer:(SMAdRendererBase *) renderer webview:(UIWebView *) webview
request:(NSURLRequest *) request navType:(UIWebViewNavigationType) navType;

@end
