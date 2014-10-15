//
//  HuidigeTijdModel.h
//  TerugTelKlok
//
//  Created by Jan-Willem Smaal on 1/3/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HuidigeTijdModel : NSObject
{
	// Pointers
	NSDate *huidigeTijd;
	NSDateFormatter *dateFormatter;
	NSTimer *timer;
	// IVARs
	Boolean running;
}

// Pointers 
@property (strong, readwrite)NSDate *huidigeTijd;
@property (strong, readwrite)NSTimer *timer;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

// Getters
@property (readonly)NSTimeInterval timerInterval;


// Class method
+ (HuidigeTijdModel*)SingletonHuidigeTijdModel;


// Instance methods
//-(instancetype)initWithTimerInterval:(float)interval NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithTimerInterval:(float)interval;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *description;

-(void)Tik;

@end
