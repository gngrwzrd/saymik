
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <UIView+Additions.h>
#import "JSON.h"
#import "defs.h"
#import "targeting.h"
#import "SMAdActionBase.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
@interface SMAdActionSMS : SMAdActionBase <MFMessageComposeViewControllerDelegate> {
	MFMessageComposeViewController * _sms;
#else
@interface SMAdActionSMS : SMAdActionBase {
	id _sms;
#endif
}

- (void) showAlert;
	
@end
