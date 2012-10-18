
#import <Foundation/Foundation.h>
#import "UIView+Additions.h"
#import "SMAd.h"
#import "SMAdLoader.h"
#import "SMAdInspector.h"
#import "SMAdActionDelegate.h"
#import "SMAdActionBase.h"
#import "SMAdBeaconDelegate.h"
#import "SMAdModel.h"
#import "defs.h"

@class SMAd;
@class SMAdBeacon;

@interface SMAdRendererBase : NSObject <SMAdActionDelegate,SMAdActionDelegate,SMAdBeaconDelegate> {
	Boolean isInTakeover;
	UIView * _view;
	UIWebView * _deviceEventsTarget;
	NSObject <SMAdDelegate> * _adDelegate;
	NSMutableArray * _actions;
	SMAd * _ad;
	SMAdModel * _model;
	SMAdLoader * _loader;
	SMAdInspector * _inspector;
	SMAdBeacon * _initBeacon;
	SMAdBeacon * _echoBeacon;
	SMAdBeacon * _amrBeacon;
	SMAdBeacon * _closeBeacon;
}


@property (nonatomic,assign) SMAd * ad;
@property (nonatomic,retain) SMAdModel * model;
@property (nonatomic,retain) SMAdLoader * loader;
@property (nonatomic,retain) SMAdInspector * inspector;
@property (nonatomic,retain) UIView * view;
@property (nonatomic,retain) NSObject <SMAdDelegate> * adDelegate;

- (void) teardown;
- (void) prepareBeacons;
- (void) setOrientation:(UIDeviceOrientation) orientation updateFrames:(Boolean) update;
- (void) appBackground;
- (void) appForeground;
- (Boolean) isInTakeover;
- (UIWindow *) getKeyWindow;

@end
