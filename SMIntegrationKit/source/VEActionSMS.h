
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <UIView+Additions.h>
#import "SMAdActionBase.h"
#import "defs.h"
#import "targeting.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
@interface VEActionSMS : SMAdActionBase <MFMessageComposeViewControllerDelegate> {
		MFMessageComposeViewController * _sms;
#else
@interface VEActionSMS : SMAdActionBase {
		id _sms;
#endif
		
}

- (void) showAlert;
	
@end
