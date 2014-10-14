//
//  FlipsideViewController.m
//  TerugTelKlok
//
//  Created by J SMAAL on 27-12-11.
//  Copyright (c) 2011 Communicatie VolZin. All rights reserved.
//

#import "FlipsideViewController.h"

@implementation FlipsideViewController
@synthesize startButton = _startButton;
@synthesize stopButton = _stopButton;
@synthesize timePicker = _timePicker;
@synthesize navigationStartStopButton = _navigationStartStopButton;
@synthesize delegate = _delegate;

- (void)awakeFromNib
{
	// Dit is waar de PopOver in gezet wordt. 
	// depricated// self.contentSizeForViewInPopover = CGSizeMake(320.0, 360.0);
    self.preferredContentSize = CGSizeMake(320.0, 360.0);
    
    
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	//TerugTelTimerModel *tmpKlokModel = [TerugTelTimerModel SingletonKlokModel];
	//[_timePicker setCountDownDuration:tmpKlokModel.interval];
	
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
	[self setStartButton:nil];
	[self setStopButton:nil];
	[self setTimePicker:nil];
	[self setNavigationStartStopButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
 
	// Return YES for supported orientations
/*	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
 */
	return YES;
}

#pragma mark - IBactions
- (IBAction)startPressed:(id)sender {
	NSTimeInterval tmpInterval = [_timePicker countDownDuration];
	if(tmpInterval != 0){
		TerugTelTimerModel *tmpKlokModel = [TerugTelTimerModel SingletonKlokModel];
		[tmpKlokModel Start];
		tmpKlokModel.interval = tmpInterval;
	
		// --- Maak een lokale notification aan. 
		UIApplication *app = [ UIApplication sharedApplication];
		
		NSArray *scheduled = [app scheduledLocalNotifications];
		if(scheduled.count){
			[app cancelAllLocalNotifications];
		}
		
		if([tmpKlokModel running]){
			UIApplication *app = [ UIApplication sharedApplication];
			
			// Haal oude notifications weg. 
			NSArray *scheduled = [app scheduledLocalNotifications];
			if(scheduled.count){
				[app cancelAllLocalNotifications];
			}
			UILocalNotification *alarm = [[UILocalNotification alloc] init];
			if(alarm){
				alarm.fireDate = tmpKlokModel.alarmTijd;
				alarm.timeZone = [NSTimeZone defaultTimeZone];
				alarm.repeatInterval = 0;
				alarm.alertBody = @"Alarm";
				alarm.alertAction = nil;
				alarm.soundName = @"alarm.caf";
				[app scheduleLocalNotification:alarm];
			}
		}
		///----
		
		// Dismiss UI. 
		[self.delegate flipsideViewControllerDidFinish:self];
	}
}


- (IBAction)stopPressed:(id)sender {
	TerugTelTimerModel *tmpKlokModel = [TerugTelTimerModel SingletonKlokModel];
	[tmpKlokModel Stop];
	
	// Haal oude notifications weg.  
	UIApplication *app = [ UIApplication sharedApplication];
	
	NSArray *scheduled = [app scheduledLocalNotifications];
	if(scheduled.count){
		[app cancelAllLocalNotifications];
	}
}


- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}


- (IBAction)timeChanged:(id)sender {
	NSTimeInterval tmpInterval =  [_timePicker countDownDuration];
	//NSLog(@"TimePicker: %@", _timePicker);
	TerugTelTimerModel *tmpKlokModel = [TerugTelTimerModel SingletonKlokModel];
	//[tmpKlokModel Start];
	tmpKlokModel.interval = tmpInterval;
	
	
	// --- Maak een lokale notification aan. 
	UIApplication *app = [ UIApplication sharedApplication];
	
	NSArray *scheduled = [app scheduledLocalNotifications];
	if(scheduled.count){
		[app cancelAllLocalNotifications];
	}
	
	if([tmpKlokModel running]){
		UIApplication *app = [ UIApplication sharedApplication];
		
		// Haal oude notifications weg. 
		NSArray *scheduled = [app scheduledLocalNotifications];
		if(scheduled.count){
			[app cancelAllLocalNotifications];
		}
		UILocalNotification *alarm = [[UILocalNotification alloc] init];
		if(alarm){
			alarm.fireDate = tmpKlokModel.alarmTijd;
			alarm.timeZone = [NSTimeZone defaultTimeZone];
			alarm.repeatInterval = 0;
			alarm.alertBody = @"Alarm";
			alarm.alertAction = nil;
			alarm.soundName = @"alarm.caf";
			[app scheduleLocalNotification:alarm];
		}
	}
	///----
	
}

- (IBAction)navigationStartStopPressed:(id)sender {
	[self startPressed:sender];
}


@end
