//
//  KlokModel.m
//  TerugTelKlok
//
//  Created by J SMAAL on 27-12-11.
//  Copyright (c) 2011 Communicatie VolZin. All rights reserved.
//

#import "TerugTelTimerModel.h"


static TerugTelTimerModel *singletonKlokModel = nil;

@implementation TerugTelTimerModel

@synthesize alarmTijd;
@synthesize beginTijd;
@synthesize aftelTijd;
@synthesize ticks;
@synthesize timer;
@synthesize running;
@synthesize alarm;
@synthesize interval;
@synthesize dateFormatter;


// If you want to use a single global alarm use this singleton class method. 
+ (TerugTelTimerModel*)SingletonKlokModel
{
    if (singletonKlokModel == nil) {
        singletonKlokModel = [[super allocWithZone:NULL] init];
    }
    return singletonKlokModel;
}



// readonly getter
-(NSTimeInterval)secondenTotAlarm{
	if(!running){
		return 0;
	}
	return [alarmTijd timeIntervalSinceDate:aftelTijd];
}


// Ondertussen werkt deze.
-(Boolean)nogMeerDanEenUurTeGaan{
	if(!running){
		return NO;
	} 
	else {
		aftelTijd = [[NSDate alloc] init];
		aftelTijd = [aftelTijd dateByAddingTimeInterval:3600];
		if([aftelTijd compare:alarmTijd] == NSOrderedAscending ){
			aftelTijd = nil;
			return YES;
		}
		else {
			aftelTijd = nil;
			return NO;
		}
	}
}


-(id)init
{
	self = [super init];
	if(self){
		timer = nil;
		running = NO;
		beginTijd = nil;
		alarmTijd = nil;
		aftelTijd = nil;
		ticks = 0;
		alarm = NO;
		
		// grmlble....  formats. 
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		NSLocale *myLocale = [[NSLocale alloc ] initWithLocaleIdentifier:@"nl_NL"];
		[dateFormatter setLocale:myLocale];
		myLocale = nil;		
	}
	return self;
}



-(NSString *)description
{
#if 0
	return [NSString 
			stringWithFormat:@"GMT! Ticks: %d, interval: %f\n\
beginTijd: %@\n\
alarmTijd:%@\n\
aftelTijd: %@", 
			ticks, interval, beginTijd, 
			alarmTijd, aftelTijd];
#endif
	return [dateFormatter stringFromDate:aftelTijd];
}
 


-(void)Start 
{
	if(interval == 0){
		
		//NSLog(@"Start: Interval is 0! cannot start!");
	}
	else{
		
		running = YES;
		alarm = NO;
		// Sets the current date automatically 
		beginTijd = [[NSDate alloc] init];
		alarmTijd = [NSDate dateWithTimeInterval:interval 
									   sinceDate:beginTijd];
		aftelTijd = [[NSDate alloc] init];
		ticks = 0;
		if (timer != nil){
			[timer invalidate];
			timer = nil;
		}
		// Send the Start notification 
		[[NSNotificationCenter defaultCenter] postNotificationName:@"KlokModelStartNotification" object:self];
		// Elke 1 seconden, hij gaat pas na 1 seconden starten dus eerste keer
		// zelf aanroepen. 
		[self Tik]; 
		timer = [NSTimer scheduledTimerWithTimeInterval:1.0
												 target:self 
											   selector:@selector(Tik) 
											   userInfo:nil 
												repeats:YES];
		//NSLog(@"start");
	}
}


-(void)Stop
{
	// Send the Stop notification 
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KlokModelStopNotification" object:self];
	[timer invalidate];
	timer = nil;
	running = NO;
	beginTijd = nil;
	//alarmTijd = nil;	// We willen eigenlijk wel weten wat deze tijd was.
	aftelTijd = nil;
	ticks = 0;
	alarm = NO;
	//NSLog(@"stop");
}


-(void)Tik
{
	// Send the Tik notification 
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KlokModelTikNotification" object:self];
	
	self.ticks = ticks + 1;
	aftelTijd = [[NSDate alloc] init];
	
	if([aftelTijd compare:alarmTijd] == NSOrderedDescending){
		// Send the alarm notifcation to the observers
		[[NSNotificationCenter defaultCenter] postNotificationName:@"KlokModelAlarmNotification" object:self];
		
		//NSLog(@"!!Alarm!!");
		[self Stop];
		alarm = YES;
		return;
	}
	else{
		//	NSLog(@"Tik: %@", self);
		return;
	}
}


@end
