//
//  KlokModel.h
//  TerugTelKlok
//
//  Created by J SMAAL on 27-12-11.
//  Copyright (c) 2011 Communicatie VolZin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TerugTelTimerModel : NSObject 
{
	// Pointers
	NSDate *alarmTijd;
	NSDate *beginTijd;
	NSDate *aftelTijd;
	NSTimer *timer;
	NSDateFormatter *dateFormatter;
	
	// IVARs
	Boolean running;
	Boolean alarm;
	NSTimeInterval interval;
	int ticks;
}

// Getters don't need ARC. 
@property (readonly)NSTimeInterval secondenTotAlarm; 
@property (readonly)Boolean nogMeerDanEenUurTeGaan;
	

// Pointers
@property (strong, readwrite)NSDate *alarmTijd;
@property (strong, readwrite)NSDate *beginTijd;
@property (strong, readwrite)NSDate *aftelTijd;
@property (strong, readwrite)NSTimer *timer;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

// IVARs
@property (assign, readonly)Boolean running;
@property (assign, readonly)Boolean alarm;

@property (assign, readwrite)NSTimeInterval interval; 
@property (assign, readwrite)int ticks; 

// If you want to use a single global alarm use this singleton class method. 
+ (TerugTelTimerModel*)SingletonKlokModel;

-(NSString *)description;

-(void)Start;
-(void)Stop;
-(void)Tik;


@end
