//
//  FlipsideViewController.h
//  TerugTelKlok
//
//  Created by J SMAAL on 27-12-11.
//  Copyright (c) 2011 Communicatie VolZin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TerugTelTimerModel.h"

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController  

#pragma mark - IBoutlets
@property (weak, nonatomic) IBOutlet id <FlipsideViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navigationStartStopButton;


#pragma mark - IBactions
- (IBAction)startPressed:(id)sender;
- (IBAction)stopPressed:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)timeChanged:(id)sender;
- (IBAction)navigationStartStopPressed:(id)sender;


@end
