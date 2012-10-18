
#import "SMAdTouchView.h"

@implementation SMAdTouchView
@synthesize delegate = _delegate;
@synthesize touchUpInside = _touchUpInside;
@synthesize swipeLeft = _swipeLeft;
@synthesize swipeRight = _swipeRight;
@synthesize sendEndIfSwiped = _sendEndIfSwiped;

- (void) motionBegan:(UIEventSubtype) motion withEvent:(UIEvent *) event {
	if(_delegate && [_delegate respondsToSelector:@selector(view:didBeginMotion:event:)]) {
		[_delegate view:self didBeginMotion:motion event:event];
	}
}

- (void) motionEnded:(UIEventSubtype) motion withEvent:(UIEvent *) event {
	if(_delegate && [_delegate respondsToSelector:@selector(view:didEndMotion:event:)]) {
		[_delegate view:self didEndMotion:motion event:event];
	}
}

- (void) motionCancelled:(UIEventSubtype) motion withEvent:(UIEvent *) event {
	if(_delegate && [_delegate respondsToSelector:@selector(view:didCancelMotion:event:)]) {
		[_delegate view:self didCancelMotion:motion event:event];
	}
}

- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event {
	UITouch * touch = [touches anyObject];
	firstTouch = [touch locationInView:self];
	if(_delegate && [_delegate respondsToSelector:@selector(view:didBeginTouches:event:)]) {
		[_delegate view:self didBeginTouches:touches event:event];
	}
}

- (void) touchesEnded:(NSSet *) touches withEvent:(UIEvent *) event {
	UITouch * touch = [touches anyObject];
	CGPoint loc = [touch locationInView:self];
	Boolean swiped = false;
	if(_touchUpInside) {
		CGRect fv = [self frame];
		if(!CGRectContainsPoint(fv,loc)) return;
	}
	if(_swipeLeft && firstTouch.x - loc.x > 40) {
		swiped = true;
		if(_delegate && [_delegate respondsToSelector:@selector(view:didSwipeLeft:event:)]) {
			[_delegate view:self didSwipeLeft:touches event:event];
		}
	}
	if(_swipeRight && firstTouch.x - loc.x < -40) {
		swiped = true;
		if(_delegate && [_delegate respondsToSelector:@selector(view:didSwipeRight:event:)]) {
			[_delegate view:self didSwipeRight:touches event:event];
		}
	}
	if(swiped && !_sendEndIfSwiped) return;
	if(_delegate && [_delegate respondsToSelector:@selector(view:didEndTouches:event:)]) {
		[_delegate view:self didEndTouches:touches event:event];
	}
}

- (void) touchesCancelled:(NSSet *) touches withEvent:(UIEvent *) event {
	if(_delegate && [_delegate respondsToSelector:@selector(view:didCancelTouches:event:)]) {
		[_delegate view:self didCancelTouches:touches event:event];
	}
}

- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *)event {
	if(_delegate && [_delegate respondsToSelector:@selector(view:didMoveTouches:event:)]) {
		[_delegate view:self didMoveTouches:touches event:event];
	}
}

@end
