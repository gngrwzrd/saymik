
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMAd.h"
#import "SMAdActionBase.h"
#import "SMAdBeacon.h"
#import "defs.h"

@interface SMAdActionTPB : SMAdActionBase {
	NSURLConnection * conn;
	SMAdBeacon * _echoBeacon;
}

@end
