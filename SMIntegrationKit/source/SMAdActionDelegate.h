
#import <UIKit/UIKit.h>
#import "SMAd.h"
#import "SMAdAction.h"
#import "SMAdError.h"

@class SMAdActionBase;

@protocol SMAdActionDelegate

@optional
- (void) actionCantContinue:(SMAdActionBase <SMAdAction> *) action reason:(_SMAdError) reason;
- (void) actionDidFinish:(SMAdActionBase <SMAdAction> *) action;
- (void) actionDidCloseTakeover:(SMAdActionBase <SMAdAction> *) action;
- (void) actionWantsToCloseTakeover:(SMAdActionBase <SMAdAction> *) action;
- (void) actionWantsToShowTakeover:(SMAdActionBase <SMAdAction> *) action;
- (void) action:(SMAdActionBase <SMAdAction> *) action wantsToFireVideoBeacons:(NSMutableArray *) beaconInfo;
- (void) action:(SMAdActionBase <SMAdAction> *) action wantsToFireVideoStartBeacon:(NSMutableArray *) beaconInfo;
- (void) actionWantsToShowVideoTakeover:(SMAdActionBase <SMAdAction> *) action;
- (void) actionDidFinishVideo:(SMAdActionBase <SMAdAction> *) action;
- (void) hideToolbar;
- (void) showToolbar;
- (void) updateFramesForV1Takeover;

@end
