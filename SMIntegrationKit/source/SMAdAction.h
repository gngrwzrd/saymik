
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SMAdAction

@required
- (BOOL) returnForUIWebView;
- (BOOL) requiresPersistence;
- (void) execute;

@end
