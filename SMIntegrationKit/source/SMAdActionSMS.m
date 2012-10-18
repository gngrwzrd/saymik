
#import "SMAdActionSMS.h"

@implementation SMAdActionSMS

- (void) showAlert {
	UIAlertView * alert = [[UIAlertView alloc] init];
	[alert setMessage:@"SMS only available in iOS 4.0 or later."];
	[alert addButtonWithTitle:@"OK"];
	[alert show];
	[alert release];
}

- (void) execute {
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 40000
	//if compiling and linking against an old SDK, we don't put
	//any code in for SMS support. They only get an alert.
	
	[self showAlert];
	return;
	
#else
	//if we compiled against a >= 4.0 SDK, use runtime checking to make
	//sure that their OS is >= 4.0. If it's < 4.0, they get alert.
	
	if([SMAdUtility iOSVersion] < 4.0) {
		[self showAlert];
		return;
	}
	
	//check to set text
	Boolean showAlert = false;
	Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
	if(smsClass == nil) {
		if(_delegate && [_delegate respondsToSelector:@selector(actionCantContinue:reason:)]) {
			[_delegate actionCantContinue:self reason:_SMAdErrorCantSendSMS];
		}
		showAlert = true;
	}
	if(smsClass != nil && ![smsClass canSendText]) {
		if(_delegate && [_delegate respondsToSelector:@selector(actionCantContinue:reason:)]) {
			[_delegate actionCantContinue:self reason:_SMAdErrorCantSendSMS];
		}
		showAlert = true;
	}
	
	//if no email show alert
	if(showAlert) {
		UIAlertView * alert = [[UIAlertView alloc] init];
		[alert setMessage:@"Sorry, sms not available."];
		[alert addButtonWithTitle:@"OK"];
		[alert show];
		[alert release];
		return;
	}
	
	//setup sms
	if(!_sms) _sms = [[MFMessageComposeViewController alloc] init];
	[_sms setMessageComposeDelegate:self];
	[_viewController setWantsFullScreenLayout:TRUE];
	[_viewController setModalPresentationStyle:UIModalPresentationFullScreen];
	
	//get parameters
	NSString * body = [_message objectForKey:@"body"];
	NSString * recs = [_message objectForKey:@"recipients"];
	NSArray * recipients = [recs componentsSeparatedByString:@","];
	[_sms setRecipients:recipients];
	[_sms setBody:body];
	[_viewController presentModalViewController:_sms animated:true];
#endif
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
- (void) messageComposeViewController:(MFMessageComposeViewController *) controller
didFinishWithResult:(MessageComposeResult) result
{
	[_viewController dismissModalViewControllerAnimated:TRUE];
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(finishLater) userInfo:nil repeats:false];
}
#endif

- (void) finishLater {
	[self finish];
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionSMS");
	#endif
	if(_sms) {
		if([[_sms view] superview]) [[_sms view] removeFromSuperview];
		[_sms release];
	}
	_sms = nil;
	[super dealloc];
}

@end
