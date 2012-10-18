
#import "VEActionEmail.h"

@implementation VEActionEmail

- (void) execute {
	Boolean showAlert = false;
	
	//check if can't send mail
	Class emailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if(emailClass == nil) {
		if(_delegate && [_delegate respondsToSelector:@selector(actionCantContinue:reason:)]) {
			[_delegate actionCantContinue:self reason:_SMAdErrorCantSendMail];
		}
		showAlert = true;
	}
	if(emailClass != nil && ![emailClass canSendMail]) {
		if(_delegate && [_delegate respondsToSelector:@selector(actionCantContinue:reason:)]) {
			[_delegate actionCantContinue:self reason:_SMAdErrorCantSendMail];
		}
		showAlert = true;
	}
	
	//if no email show alert
	if(showAlert) {
		UIAlertView * alert = [[UIAlertView alloc] init];
		[alert setMessage:@"Sorry, email not available."];
		[alert addButtonWithTitle:@"OK"];
		[alert show];
		[alert release];
		return;
	}
	
	//setup message composer
	if(!_mail) _mail = [[MFMailComposeViewController alloc] init];
	NSURL * url = [_request URL];
	NSString * subj = [NSString stringWithFormat:@"mailSubject(%@)",[url host]];
	NSString * subject = [_webview stringByEvaluatingJavaScriptFromString:subj];
	NSString * bod = [NSString stringWithFormat:@"mailBody(%@)", [url host]];
	NSString * body = [_webview stringByEvaluatingJavaScriptFromString:bod];
	[_mail setSubject:subject];
	[_mail setMessageBody:body isHTML:NO];
	[_mail setMailComposeDelegate:self];
	
	//show message composer
	CGRect screen = [UIScreen mainScreen].bounds;
	float height = screen.size.height;
	float width = screen.size.width;
	[[_mail view] setFrame:CGRectMake(0,height,width,height)];
	[UIView beginAnimations:@"showMessageComposer" context:nil];
	[[[UIApplication sharedApplication] keyWindow] addSubview:[_mail view]];
	[_mail.view setFrame:CGRectMake(0,0,width,height)];
	[UIView commitAnimations];
}

- (void) mailComposeController:(MFMailComposeViewController *) controller
		   didFinishWithResult:(MFMailComposeResult) result error:(NSError *) error
{
	[[_mail view] removeFromSuperview];
	[self finish];
}

- (BOOL) returnForUIWebView {
	return NO;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: VEActionEmail");
	#endif
	if(_mail) {
		[_mail setDelegate:nil];
		if([[_mail view] superview]) [[_mail view] removeFromSuperview];
		[_mail release];
	}
	_mail = nil;
	[super dealloc];
}

@end
