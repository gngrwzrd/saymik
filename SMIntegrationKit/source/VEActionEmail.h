
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "SMAdActionBase.h"
#import "UIView+Additions.h"
#import "defs.h"

@interface VEActionEmail : SMAdActionBase <MFMailComposeViewControllerDelegate> {
	MFMailComposeViewController * _mail;
}

@end
