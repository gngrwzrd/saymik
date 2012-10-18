
#import "SMAdActionEmail.h"

@implementation SMAdActionEmail

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
	
	[_mail setMailComposeDelegate:self];
	NSString * subj = [_message objectForKey:@"subject"];
	if(!subj) subj = [_message objectForKey:@"subj"];
	NSString * body = [_message objectForKey:@"body"];
	NSString * toad = [_message objectForKey:@"to"];
	if(toad) {
		NSArray * recips = [NSArray arrayWithObject:toad];
		[_mail setToRecipients:recips];
	}
	[_mail setSubject:subj];
	[_mail setMessageBody:body isHTML:FALSE];
	
	//check for attachments
	NSString * attachment = [_message objectForKey:@"attachment"];
	NSString * mime = [_message objectForKey:@"attachmentMimeType"];
	NSString * attachmentFileType = [_message objectForKey:@"attachmentFileType"];
	if(!mime) mime = @"image/png";
	if(!attachmentFileType) attachmentFileType = @"png";
	if(attachment) {
		NSString * filename = [NSString stringWithFormat:@"attachment.@%",attachmentFileType];
		NSURL * url = [NSURL URLWithString:attachment];
		NSData * data = [NSData dataWithContentsOfURL:url];
		[_mail addAttachmentData:data mimeType:mime fileName:filename];
	}
	
	[_viewController presentModalViewController:_mail animated:TRUE];
}

- (void) mailComposeController:(MFMailComposeViewController *) controller
didFinishWithResult:(MFMailComposeResult) result error:(NSError *) error
{
	[_viewController dismissModalViewControllerAnimated:TRUE];
	[_mail setMailComposeDelegate:nil];
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(finishLater) userInfo:nil repeats:false];
}

- (void) finishLater {
	[self finish];
}

- (BOOL) returnForUIWebView {
	return NO;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionEmail");
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
