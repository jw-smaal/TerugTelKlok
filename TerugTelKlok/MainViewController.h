//
//  MainViewController.h
//  TerugTelKlok
//
//  Created by J SMAAL on 27-12-11.
//  Copyright (c) 2011 Communicatie VolZin. All rights reserved.
//
// 

// For playing audio stuff. 
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

// Models
#import "TerugTelTimerModel.h"
#import "HuidigeTijdModel.h"

// Views
#import "KlokLayerDelegate.h"



// Controllers
#import "FlipsideViewController.h"

@interface MainViewController : UIViewController <KlokLayerDelegate, FlipsideViewControllerDelegate, UIPopoverControllerDelegate>
{
	
	// Models
	TerugTelTimerModel *klokmodel;
	HuidigeTijdModel *huidigetijdmodel;
	AVAudioPlayer *audioPlayer;
	CGPoint tappoint; 
	
	// Views
	CALayer *myKlokLayer;
	KlokLayerDelegate *myKlokLayerDelegate; 
	UIAlertView *alertView;


	// Controllers
	UIPanGestureRecognizer *panRecognizer;	
	
	// Interface
	__weak IBOutlet UIView *mainView;
}	

// Models
@property (strong, nonatomic) TerugTelTimerModel *klokmodel;
@property (strong, nonatomic) HuidigeTijdModel *huidigetijdmodel;


//Controllers
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (strong, nonatomic)  UIPanGestureRecognizer *panRecognizer;


// Interface
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *huidigeTijdLabel;
@property (strong, nonatomic) UIAlertView *alertView;

// We are observing the KlokModel and these get called. 
// -(void)handleKlokModelAlarm:(NSNotification *)note;
-(void)handleKlokModelTik:(NSNotification *)note;
-(void)handleHuidigeTijdModelTik:(NSNotification *)note;

@end
