
#import <UIKit/UIKit.h>

@class SMAdTouchView;

@protocol SMAdTouchViewDelegate

@optional
- (void) view:(SMAdTouchView *) view didBeginTouches:(NSSet *) touches event:(UIEvent *) event;
- (void) view:(SMAdTouchView *) view didEndTouches:(NSSet *) touches event:(UIEvent *) event;
- (void) view:(SMAdTouchView *) view didMoveTouches:(NSSet *) touches event:(UIEvent *) event;
- (void) view:(SMAdTouchView *) view didCancelTouches:(NSSet *) touches event:(UIEvent *) event;
- (void) view:(SMAdTouchView *) view didSwipeLeft:(NSSet *) touches event:(UIEvent *) event;
- (void) view:(SMAdTouchView *) view didSwipeRight:(NSSet *) touches event:(UIEvent *) event;
- (void) view:(SMAdTouchView *) view didBeginMotion:(UIEventSubtype) motion event:(UIEvent *) event;
- (void) view:(SMAdTouchView *) view didEndMotion:(UIEventSubtype) motion event:(UIEvent *) event;
- (void) view:(SMAdTouchView *) view didCancelMotion:(UIEventSubtype) motion event:(UIEvent *) event;

@end
