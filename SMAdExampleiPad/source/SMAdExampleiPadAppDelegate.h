//
//  SMAdExampleiPadAppDelegate.h
//  SMAdExampleiPad
//
//  Created by Aaron Smith on 3/18/11.
//  Copyright 2011 Videoegg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMAdExampleiPadViewController;

@interface SMAdExampleiPadAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SMAdExampleiPadViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SMAdExampleiPadViewController *viewController;

@end

