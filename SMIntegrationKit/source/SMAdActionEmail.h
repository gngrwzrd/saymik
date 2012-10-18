
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "SMAdActionBase.h"
#import "UIView+Additions.h"
#import "defs.h"

@interface SMAdActionEmail : SMAdActionBase <MFMailComposeViewControllerDelegate> {
	MFMailComposeViewController * _mail;
}

@end
