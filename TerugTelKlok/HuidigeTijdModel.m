//
//  HuidigeTijdModel.m
//  TerugTelKlok
//
//  Created by Jan-Willem Smaal on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HuidigeTijdModel.h"

static HuidigeTijdModel *singletonHuidigeTijdModel = nil;

@implementation HuidigeTijdModel

@synthesize huidigeTijd;
@synthesize timer;
@synthesize dateFormatter;

#pragma mark - Constructors
-(id)init
{
	self = [super init];
	if(self){
		running = YES;
		// Sets the current date automatically 
		huidigeTijd = [[NSDate alloc] init];
		
		// grmlble....  formats. 
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		
		//NSLocale *nlLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"nl_NL"];
		//[dateFormatter setLocale:nlLocale];
		NSLocale *myLocale = [[NSLocale alloc ] initWithLocaleIdentifier:@"nl_NL"];
		[dateFormatter setLocale:myLocale];
		myLocale = nil;
		
#if 0	// Niet nodig! 
		[[NSNotificationCenter defaultCenter] 
		 addObserver:NSCurrentLocaleDidChangeNotification 
		 selector:@selector(handleLocaleDidChangeNotification:) 
		 name:@"NSCurrentLocaleDidChangeNotification" 
		 object:self];
#endif
		
		// Elke 1 seconden, hij gaat pas na 1 seconden starten dus eerste keer
		// zelf aanroepen. 
		if (timer != nil){
			[timer invalidate];
			timer = nil;
		}
		[self Tik]; 
		timer = [NSTimer scheduledTimerWithTimeInterval:1.0
												 target:self 
											   selector:@selector(Tik) 
											   userInfo:nil 
												repeats:YES];
		//NSLog(@"start");
	}
	return self;
}


-(id)initWithTimerInterval:(float)interval
{
	self = [super init];
	if(self){
		running = YES;
		// Sets the current date automatically 
		huidigeTijd = [[NSDate alloc] init];
		if (timer != nil){
			[timer invalidate];
			timer = nil;
		}
		[self Tik]; 
		timer = [NSTimer scheduledTimerWithTimeInterval:interval
												 target:self 
											   selector:@selector(Tik) 
											   userInfo:nil 
												repeats:YES];
		//NSLog(@"start");
	}
	return self;
}

#pragma mark - Getters
-(NSTimeInterval)timerInterval
{
	if(timer == nil){
		return 0.0;
	}
	else {
		return [timer timeInterval];
	}
}



-(NSString *)description
{
	return [dateFormatter stringFromDate:huidigeTijd];
}
 


#pragma mark - Class Methods
// If you want to use a single global alarm use this singleton class method. 
+ (HuidigeTijdModel*)SingletonHuidigeTijdModel
{
    if (singletonHuidigeTijdModel == nil) {
        singletonHuidigeTijdModel = [[super allocWithZone:NULL] init];
    }
    return singletonHuidigeTijdModel;
}


#pragma mark - Instance Methods 
-(void)Tik
{
	// Send the Tik notification 
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HuidigeTijdModelTikNotification" object:self];
	huidigeTijd = [[NSDate alloc] init];
}




@end
