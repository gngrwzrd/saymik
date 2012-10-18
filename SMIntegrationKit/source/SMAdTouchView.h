
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMAdTouchViewDelegate.h"

@interface SMAdTouchView : UIView {
	CGPoint firstTouch;
	NSObject <SMAdTouchViewDelegate> * _delegate;
	Boolean _touchUpInside;
	Boolean _swipeRight;
	Boolean _swipeLeft;
	Boolean _sendEndIfSwiped;
}

@property (nonatomic,assign) NSObject <SMAdTouchViewDelegate> * delegate;
@property (nonatomic,assign) Boolean touchUpInside;
@property (nonatomic,assign) Boolean swipeLeft;
@property (nonatomic,assign) Boolean swipeRight;
@property (nonatomic,assign) Boolean sendEndIfSwiped;

@end
