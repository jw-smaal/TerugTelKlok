//
//  MainViewController.m
//  TerugTelKlok
//
//  Created by J SMAAL on 27-12-11.
//  Copyright (c) 2011 Communicatie VolZin. All rights reserved.
//

#import "MainViewController.h"

#define MAINVIEW_DEBUGGING 0
@implementation MainViewController

// Model
@synthesize klokmodel;
@synthesize huidigetijdmodel;

// View
@synthesize mainLabel;
@synthesize huidigeTijdLabel;
@synthesize mainView;
@synthesize alertView;


// Controller
@synthesize flipsidePopoverController = _flipsidePopoverController;
@synthesize panRecognizer;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
	audioPlayer = nil;
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

	// Setup models 
	klokmodel = [TerugTelTimerModel SingletonKlokModel];
	huidigetijdmodel = [HuidigeTijdModel SingletonHuidigeTijdModel];

    
    
	/**
	 * Notifications 
	 */
    
    // Vraag de gebruiker om toestemming voor de NSNotification
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    
    // TODO: check of the gebruiker toestemming heeft gegeven.
    
    // We willen een notifcation krijgen als een Alarm klok tik binnen komt.
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(handleKlokModelTik:) name:@"KlokModelTikNotification" 
	 object:klokmodel];
	
	// We willen een notification krijgen als een huidige tijd tik binnen komt. 	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(handleHuidigeTijdModelTik:) name:@"HuidigeTijdModelTikNotification" 
	 object:huidigetijdmodel];
	
	//mainLabel.text = [NSString stringWithFormat:@""];	
	
	myKlokLayer = [[CALayer alloc] init];	
	myKlokLayerDelegate = [[KlokLayerDelegate alloc] init];
	myKlokLayerDelegate.delegate = self; // We Implement this protocol 
	myKlokLayer.delegate = myKlokLayerDelegate;
	
	// Important, spent ages on getting this right.  //
	myKlokLayer.frame = mainView.layer.bounds;
	myKlokLayer.bounds = mainView.layer.bounds;
	///////////////////
	
	myKlokLayer.name = @"background";
	myKlokLayer.opacity = 1.0;
	myKlokLayer.backgroundColor = [UIColor whiteColor].CGColor;
	myKlokLayer.masksToBounds = YES;
	myKlokLayer.needsDisplayOnBoundsChange = YES;
	[myKlokLayer setNeedsDisplay];	
	
	// Finally add this as a sublayer to mainView
	[mainView.layer addSublayer:myKlokLayer];
	mainView.layer.backgroundColor = [UIColor whiteColor].CGColor;
	mainView.layer.needsDisplayOnBoundsChange = YES;

#if MAINVIEW_DEBUGGING
	/** 
	 * Taps
	 */
	panRecognizer = [[UIPanGestureRecognizer alloc] 
					 initWithTarget:self 
					 action:@selector(foundpan:)];
	//panRecognizer.numberOfTouchesRequired = 1; 
	[mainView addGestureRecognizer:panRecognizer];
	// the previous line retains so we don't need the reference.  
	panRecognizer = nil;
	mainLabel.enabled = YES;
	mainLabel.hidden = NO;
	huidigeTijdLabel.enabled = YES;
	huidigeTijdLabel.hidden = NO;
#else 
	mainLabel.enabled = NO;
	mainLabel.hidden = YES;
	huidigeTijdLabel.enabled = NO;
	huidigeTijdLabel.hidden = YES;
#endif	
	
	
}


- (void)viewDidUnload
{
	[self setMainLabel:nil];
	mainView = nil;
	[self setMainView:nil];
	[self setHuidigeTijdLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	mainLabel.text = @"";
	huidigeTijdLabel.text = @"";

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
	return YES;
}

// Important...  spent ages on getting this right.... 
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	myKlokLayer.frame = mainView.layer.bounds;
}




/**
 * 
 */
#pragma mark - Flipside View Controller
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        // Voor de ipad de popovercontroller gebruiken. 
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}



/**
 * Touch tap handler - Updates cgpoint when touched. 
 */
#pragma mark - Touch pan handler
-(void)foundpan:(UITapGestureRecognizer *)recognizer
{
	CGPoint point = [recognizer locationInView:recognizer.view];
	
	tappoint = point;
	#if MAINVIEW_DEBUGGING
	NSLog(@"foundpan %f:%f (%@)", point.x, point.y, recognizer);
	#endif	
}


/**
 * 
 */
#pragma mark - TerugTel and  Huidige Tijd Model  notifications handlers
-(void)handleKlokModelTik:(NSNotification *)note
{
#if MAINVIEW_DEBUGGING
	//int uren = klokmodel.secondenTotAlarm/3600;
	//int minuten = klokmodel.secondenTotAlarm/60 - (uren * 60); 
	//int seconden = klokmodel.secondenTotAlarm - (uren*3600) - (minuten*60);
	

	mainLabel.text = [[NSString alloc] initWithFormat:@"alarm %@", klokmodel.alarmTijd];	
	//mainLabel.text = [[NSString alloc] initWithFormat:@"alarm %2.2d:%2.2d:%2.2d", uren, minuten, seconden];	
#endif	
	
	[myKlokLayer setNeedsDisplay];
}

-(void)handleHuidigeTijdModelTik:(NSNotification *)note
{
	// Dit is: GMT!!! 
	huidigeTijdLabel.text = [huidigetijdmodel description];

	[myKlokLayer setNeedsDisplay];
}



/**
 * KlokLayer delegate
 */
#pragma mark KlokLayer delegate protocol 
-(Boolean)TimerRunningForKlokLayer:(KlokLayerDelegate *)requestor{
	return [klokmodel running];
}



-(NSDateComponents *) DateComponentsForKlokLayer:(KlokLayerDelegate *)requestor 
{
	NSCalendar *tempCal =[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComp = [tempCal components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:huidigetijdmodel.huidigeTijd];
	//NSLog(@"DateComponentsForKlokView: %@", dateComp);	
	return dateComp;
}


-(NSDateComponents *) DateComponentsAlarmTijdForKlokLayer:(KlokLayerDelegate *)requestor 
{
	NSCalendar *tempCal =[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	// FIXME ???
    if (klokmodel.alarmTijd == nil ) {
        NSDateComponents *dateComp = [tempCal components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:huidigetijdmodel.huidigeTijd];
        return dateComp;
        
    }
    else {
        NSDateComponents *dateComp = [tempCal components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:klokmodel.alarmTijd];
        return dateComp;
    }
	//NSLog(@"DateComponentsForKlokView: %@", dateComp);
	//return dateComp;
}


-(Boolean)NogMeerDanEenUurTeGaanForKlokLayer:(KlokLayerDelegate *)requestor 
{
	return [klokmodel nogMeerDanEenUurTeGaan];
}


-(CGPoint) TapPointForKlokViewLayer:(KlokLayerDelegate *)requestor
{
	return tappoint;
}

/* END CUSTOM_LAYER_DELEGATE */


@end
