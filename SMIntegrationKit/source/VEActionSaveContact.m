
#import "VEActionSaveContact.h"

@implementation VEActionSaveContact

- (void) execute {
	NSURL * url  = [_request URL];
	NSString * funcName = [url host];
	NSString * callback = [NSString stringWithFormat:@"%@()",funcName];
	NSString * jsonStr = [_webview stringByEvaluatingJavaScriptFromString:callback];
	SBJsonParser * json = [[SBJsonParser alloc] init];
    NSError * error = nil;
    NSDictionary * contact = [json objectWithString:jsonStr error:&error];
    ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef person = ABPersonCreate();
    NSString * val = [contact objectForKey:@"org"];
	if(val) ABRecordSetValue(person, kABPersonOrganizationProperty, val, NULL);
	if(val = [contact objectForKey:@"fn"]) ABRecordSetValue(person, kABPersonFirstNameProperty, val, NULL);
	if(val = [contact objectForKey:@"ln"]) ABRecordSetValue(person, kABPersonLastNameProperty, val, NULL);      
    if(val = [contact objectForKey:@"we"]) {
		ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		ABMultiValueAddValueAndLabel(multiEmail, val, kABWorkLabel, NULL);
		ABRecordSetValue(person, kABPersonEmailProperty, multiEmail, nil); 
		CFRelease(multiEmail);
    }
    if(val = [contact objectForKey:@"img"]) {
		NSData * img = [NSData dataWithContentsOfURL:[NSURL URLWithString:val]];
		ABPersonSetImageData(person, (CFDataRef)img,nil);
    }
    if(val = [contact objectForKey:@"w#"]) {
        ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiPhone, val, kABPersonPhoneMainLabel, NULL);
        ABRecordSetValue(person, kABPersonPhoneProperty, multiPhone, nil);        
        CFRelease(multiPhone);
	}
    if(val = [contact objectForKey:@"url"]) {
        ABMutableMultiValueRef urlMultiValue =  ABMultiValueCreateMutable(kABStringPropertyType);
        ABMultiValueAddValueAndLabel(urlMultiValue, val, kABPersonHomePageLabel, NULL);
        ABRecordSetValue(person, kABPersonURLProperty, urlMultiValue, nil);
        CFRelease(urlMultiValue);        
	}
    Boolean addr = [contact objectForKey:@"str"]||[contact objectForKey:@"city"]||[contact objectForKey:@"state"]||[contact objectForKey:@"zip"];
	if(addr) {
		ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
		NSMutableDictionary * addressDictionary = [NSMutableDictionary dictionary];
		if(val = [contact objectForKey:@"str"])
			[addressDictionary setObject:val forKey:(NSString *)kABPersonAddressStreetKey];
		if(val = [contact objectForKey:@"city"])
			[addressDictionary setObject:val forKey:(NSString *)kABPersonAddressCityKey];
		if(val = [contact objectForKey:@"state"])
			[addressDictionary setObject:val forKey:(NSString *)kABPersonAddressStateKey];
		if(val = [contact objectForKey:@"zip"])
			[addressDictionary setObject:val forKey:(NSString *)kABPersonAddressZIPKey];
		ABMultiValueAddValueAndLabel(multiAddress,addressDictionary,kABWorkLabel,NULL);
		ABRecordSetValue(person,kABPersonAddressProperty,multiAddress,NULL);
		CFRelease(multiAddress);
	}
    
	ABAddressBookAddRecord(addressBook,person,nil);
	ABAddressBookSave(addressBook,nil);
    CFRelease(person);
	CFRelease(addressBook);
	[json release];
}

- (Boolean) requiresPersistance {
	return FALSE;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: VEActionSaveContact");
	#endif
	[super dealloc];
}

@end
