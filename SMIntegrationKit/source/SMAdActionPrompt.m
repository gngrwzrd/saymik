
#import "SMAdActionPrompt.h"

@implementation SMAdActionPrompt

- (void) execute {
	NSString * msg = [_message objectForKey:@"message"];
	if(!msg) msg = [_message objectForKey:@"msg"];
	if(!msg) {
		[self finish];
		return;
	}
	UIAlertView * alert = [[UIAlertView alloc] init];
	if([_message objectForKey:@"noAction"] || [_message objectForKey:@"noCallback"]) {
		[alert addButtonWithTitle:@"No"];
	}
	if([_message objectForKey:@"cancelAction"] || [_message objectForKey:@"cancelCallback"]) {
		[alert addButtonWithTitle:@"Cancel"];
	}
	if([_message objectForKey:@"yesAction"] || [_message objectForKey:@"yesCallback"]) {
		[alert addButtonWithTitle:@"Yes"];
	}
	if([_message objectForKey:@"okAction"] || [_message objectForKey:@"okCallback"]) {
		[alert addButtonWithTitle:@"OK"];
	}
	[alert setMessage:msg];
	[alert setDelegate:self];
	[alert show];
	[alert autorelease];
}

- (void) alertView:(UIAlertView *) alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
	NSString * f = NULL;
	NSString * a = NULL;
	NSString * ac = NULL;
	NSString * title = [alertView buttonTitleAtIndex:buttonIndex];
	if([title isEqualToString:@"Yes"] && [_message objectForKey:@"yesAction"]) {
		a = @"processActionsForId('%@')";
		ac = [NSString stringWithFormat:a,[_message objectForKey:@"yesAction"]];
		[_webview stringByEvaluatingJavaScriptFromString:ac];
	}
	if([title isEqualToString:@"Yes"] && [_message objectForKey:@"yesCallback"]) {
		f = [NSString stringWithFormat:@"%@()",[_message objectForKey:@"yesCallback"]];
		[_webview stringByEvaluatingJavaScriptFromString:f];
	}
	if([title isEqualToString:@"No"] && [_message objectForKey:@"noAction"]) {
		a = @"processActionsForId('%@')";
		ac = [NSString stringWithFormat:a,[_message objectForKey:@"noAction"]];
		[_webview stringByEvaluatingJavaScriptFromString:ac];
	}
	if([title isEqualToString:@"No"] && [_message objectForKey:@"noCallback"]) {
		f = [NSString stringWithFormat:@"%@()",[_message objectForKey:@"noCallback"]];
		[_webview stringByEvaluatingJavaScriptFromString:f];
	}
	if([title isEqualToString:@"OK"] && [_message objectForKey:@"okAction"]) {
		a = @"processActionsForId('%@')";
		ac = [NSString stringWithFormat:a,[_message objectForKey:@"okAction"]];
		[_webview stringByEvaluatingJavaScriptFromString:ac];
	}
	if([title isEqualToString:@"OK"] && [_message objectForKey:@"okCallback"]) {
		f = [NSString stringWithFormat:@"%@()",[_message objectForKey:@"okCallback"]];
		[_webview stringByEvaluatingJavaScriptFromString:f];
	}
	if([title isEqualToString:@"Cancel"] && [_message objectForKey:@"cancelAction"]) {
		a = @"processActionsForId('%@')";
		ac = [NSString stringWithFormat:a,[_message objectForKey:@"cancelAction"]];
		[_webview stringByEvaluatingJavaScriptFromString:ac];
	}
	if([title isEqualToString:@"Cancel"] && [_message objectForKey:@"cancelCallback"]) {
		f = [NSString stringWithFormat:@"%@()",[_message objectForKey:@"cancelCallback"]];
		[_webview stringByEvaluatingJavaScriptFromString:f];
	}
	[self finish];
}

- (void) alertViewCancel:(UIAlertView *) alertView {
	[self finish];
}

- (BOOL) requiresPersistance {
	return TRUE;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionPrompt");
	#endif
	[super dealloc];
}

@end
