//
//  AppDelegate.h
//  TerugTelKlok
//
//  Created by J SMAAL on 27-12-11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// For playing audio stuff. 
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

// Models
#import "TerugTelTimerModel.h"
#import "HuidigeTijdModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
	TerugTelTimerModel *klokmodel;
	HuidigeTijdModel *huidigetijdmodel;	
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TerugTelTimerModel *klokmodel;
@property (strong, nonatomic) HuidigeTijdModel *huidigetijdmodel;

@end
