//
//  HuidigeTijdModel.h
//  TerugTelKlok
//
//  Created by Jan-Willem Smaal on 1/3/12.
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
-(id)initWithTimerInterval:(float)interval;
-(NSString *)description;

-(void)Tik;

@end
