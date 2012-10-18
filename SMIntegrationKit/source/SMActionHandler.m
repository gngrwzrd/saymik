
#import "SMActionHandler.h"

@implementation SMActionHandler

+ (SMAdActionBase *)
createActionWithRenderer:(SMAdRendererBase *) renderer webview:(UIWebView *) webview
request:(NSURLRequest *) request navType:(UIWebViewNavigationType) navType
{
	//vars
	Class action_class = NULL;
	NSDictionary * message = NULL;
	NSURL * url = [request URL];
	NSString * scheme = [url scheme];
	
	//check for normal link
	BOOL link = ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]);
	if(link) action_class = [SMAdActionLaunchURL class];
	
	//check for old ve scheme
	if([scheme isEqualToString:@"veemail"]) action_class = [VEActionEmail class];
	if([scheme isEqualToString:@"video"]) action_class = [VEActionVideo class];
	if([scheme isEqualToString:@"vealert"]) action_class = [VEActionAlert class];
	if([scheme isEqualToString:@"vesaveimg"]) action_class = [VEActionSaveImage class];
	if([scheme isEqualToString:@"veurl"]) action_class = [VEActionURL class];
	if([scheme isEqualToString:@"vect"]) action_class = [VEActionSaveContact class];
	if([scheme isEqualToString:@"vesms"]) action_class = [VEActionSMS class];
	if([scheme isEqualToString:@"veclose"]) action_class = [VEActionClose class];
	
	//new sm scheme
	if([scheme isEqualToString:@"sm"]) {
		//get json payload
		SBJsonParser * json = [[SBJsonParser alloc] init];
		NSString * jsonstr = [[[request URL] absoluteString] stringByReplacingOccurrencesOfString:@"sm://" withString:@""];
		NSString * unescaped = [jsonstr stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		message = [json objectWithString:unescaped];
		[json release];
		
		//select action
		NSString * action_type = [message objectForKey:@"action"];
		if([action_type isEqualToString:@"email"]) action_class = [SMAdActionEmail class];
		if([action_type isEqualToString:@"contact"]) action_class = [SMAdActionSaveContact class];
		if([action_type isEqualToString:@"printf"]) action_class = [SMAdActionPrintf class];
		if([action_type isEqualToString:@"call"]) action_class = [SMAdActionMethodCall class];
		if([action_type isEqualToString:@"sms"]) action_class = [SMAdActionSMS class];
		if([action_type isEqualToString:@"image"]) action_class = [SMAdActionSaveImage class];
		if([action_type isEqualToString:@"phone"]) action_class = [SMAdActionPhone class];
		if([action_type isEqualToString:@"close"]) action_class = [SMAdActionClose class];
		if([action_type isEqualToString:@"video"]) action_class = [SMAdActionVideo class];
		if([action_type isEqualToString:@"url"]) action_class = [SMAdActionLaunchURL class];
		if([action_type isEqualToString:@"prompt"]) action_class = [SMAdActionPrompt class];
		if([action_type isEqualToString:@"alert"]) action_class = [SMAdActionAlert class];
		if([action_type isEqualToString:@"takeover"]) action_class = [SMAdActionShowTakeover class];
		if([action_type isEqualToString:@"tpb"]) action_class = [SMAdActionTPB class];
	}
	
	SMAdActionBase * action = [[action_class alloc] init];
	[action setRenderer:renderer];
	[action setSelcontext:renderer];
	[action setRequest:request];
	[action setMessage:message];
	[action setWebview:webview];
	[action setDelegate:(NSObject *)renderer];
	return [action autorelease];
}

@end
