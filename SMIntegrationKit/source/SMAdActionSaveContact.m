
#import "SMAdActionSaveContact.h"

@implementation SMAdActionSaveContact

- (void) execute {
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef person = ABPersonCreate();
	NSString * val = NULL;
	if(val = [_message objectForKey:@"org"]) ABRecordSetValue(person,kABPersonOrganizationProperty,val,NULL);
	if(val = [_message objectForKey:@"fn"]) ABRecordSetValue(person,kABPersonFirstNameProperty,val,NULL);
	if(val = [_message objectForKey:@"ln"]) ABRecordSetValue(person,kABPersonLastNameProperty,val,NULL);
	if(val = [_message objectForKey:@"we"]) {
		ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		ABMultiValueAddValueAndLabel(multiEmail,val,kABWorkLabel,NULL);
		ABRecordSetValue(person,kABPersonEmailProperty,multiEmail,NULL);
		CFRelease(multiEmail);
	}
	if(val = [_message objectForKey:@"img"]) {
		NSData * img = [NSData dataWithContentsOfURL:[NSURL URLWithString:val]];
		ABPersonSetImageData(person,(CFDataRef)img,nil);
	}
	if(val = [_message objectForKey:@"w#"]) {
		ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		ABMultiValueAddValueAndLabel(multiPhone,val,kABPersonPhoneMainLabel,NULL);
		ABRecordSetValue(person,kABPersonPhoneProperty,multiPhone,NULL);
		CFRelease(multiPhone);
	}
	if(val = [_message objectForKey:@"url"]) {
		ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutable(kABStringPropertyType);
		ABMultiValueAddValueAndLabel(urlMultiValue,val,kABPersonHomePageLabel,NULL);
		ABRecordSetValue(person,kABPersonURLProperty,urlMultiValue,NULL);
		CFRelease(urlMultiValue);
	}
	Boolean addr = [_message objectForKey:@"str"]||[_message objectForKey:@"city"]||[_message objectForKey:@"state"]||[_message objectForKey:@"zip"];
	if(addr) {
		ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
		NSMutableDictionary * addressDictionary = [NSMutableDictionary dictionary];
		if(val = [_message objectForKey:@"str"])
			[addressDictionary setObject:val forKey:(NSString *)kABPersonAddressStreetKey];
		if(val = [_message objectForKey:@"city"])
			[addressDictionary setObject:val forKey:(NSString *)kABPersonAddressCityKey];
		if(val = [_message objectForKey:@"state"])
			[addressDictionary setObject:val forKey:(NSString *)kABPersonAddressStateKey];
		if(val = [_message objectForKey:@"zip"])
			[addressDictionary setObject:val forKey:(NSString *)kABPersonAddressZIPKey];
		ABMultiValueAddValueAndLabel(multiAddress,addressDictionary,kABWorkLabel,NULL);
		ABRecordSetValue(person,kABPersonAddressProperty,multiAddress,NULL);
		CFRelease(multiAddress);
	}
	ABAddressBookAddRecord(addressBook,person,nil);
	ABAddressBookSave(addressBook,nil);
	CFRelease(person);
	CFRelease(addressBook);
	[self finish];
}

- (BOOL) returnForUIWebView {
	return FALSE;
}

- (BOOL) requiresPersistence {
	return FALSE;
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdActionSaveContact");
	#endif
	[super dealloc];
}

@end
