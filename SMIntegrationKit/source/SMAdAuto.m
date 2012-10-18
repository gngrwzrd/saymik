
#import "SMAdAuto.h"
#import "defs.h"

@implementation SMAdAuto
@synthesize tickTime = _tickTime;
@synthesize delegate = _delegate;

- (id) init {
	if(!(self = [super init])) return nil;
	_tickTime = 10;
	return self;
}

- (Boolean) isRunning {
	return [_timer isValid];
}

- (void) start {
	if(_timer) return;
	_timer = [NSTimer scheduledTimerWithTimeInterval:_tickTime
	target:self selector:@selector(timerTick) userInfo:nil repeats:true];
}

- (void) stop {
	if(!_timer) return;
	[_timer invalidate];
	_timer = NULL;
}

- (void) timerTick {
	if(_delegate && [_delegate respondsToSelector:@selector(autoDidTick:)]) {
		[_delegate autoDidTick:self];
	}
}

- (void) dealloc {
	#ifdef SMAdPrintDeallocs
	NSLog(@"DEALLOC: SMAdAuto");
	#endif
	[self setDelegate:nil];
	[_timer release];
	_timer = nil;
	_tickTime = 0;
	[super dealloc];
}

@end
