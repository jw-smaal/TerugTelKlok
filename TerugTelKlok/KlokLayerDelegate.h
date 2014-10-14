//
//  KlokLayerDelegate.h
//  TerugTelKlok
//
//  Created by J SMAAL on 06-01-12.
//  Copyright (c) 2012 Communicatie VolZin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class KlokLayerDelegate;

@protocol KlokLayerDelegate
-(Boolean) TimerRunningForKlokLayer:(KlokLayerDelegate *)requestor;
-(NSDateComponents *) DateComponentsForKlokLayer:(KlokLayerDelegate *)requestor;
-(NSDateComponents *) DateComponentsAlarmTijdForKlokLayer:(KlokLayerDelegate *)requestor;
-(CGPoint) TapPointForKlokViewLayer:(KlokLayerDelegate *)requestor;
-(Boolean)NogMeerDanEenUurTeGaanForKlokLayer:(KlokLayerDelegate *)requestor; 
@end


@interface KlokLayerDelegate : NSObject
{
	CGRect drawingRect;
	float radius;
	__weak id <KlokLayerDelegate> delegate;
}

@property (nonatomic) CGRect drawingRect; 
@property (atomic, weak) id <KlokLayerDelegate> delegate;
@property (nonatomic,readwrite) float radius;


// Instance Methods
-(void)drawKlokBackground:(CGContextRef)context;


-(void)drawPieShapeMinutenInKlok:(CGContextRef)context
			   fromCijfer:(long)fromCijfer
				 toCijfer:(long)toCijfer;

// 2 versie 
-(void)drawPieShapeUurInKlok:(CGContextRef)context
				  huidigeTijd:(NSDateComponents *)huidigeTijd
					alarmTijd:(NSDateComponents *)alarmTijd;

-(void)drawUrenWijzerContext:(CGContextRef)context 
						 uur:(long)uur
					 minuten:(long)minuten;

-(void)drawMinutenWijzer:(CGContextRef)context 
				 opGetal:(long)getal;


// Class Methods
+(void)drawMyCircle:(CGContextRef)context 
			atPoint:(CGPoint)atpoint;


@end
