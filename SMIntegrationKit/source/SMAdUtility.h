
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

bool accelerometerIsShaking(UIAcceleration * last, UIAcceleration * current, double threshold);

@interface SMAdUtility : NSObject {

}

+ (BOOL) isPad;
+ (float) iOSVersion;
+ (NSString *) urlencodeString:(NSString *) str;

@end
