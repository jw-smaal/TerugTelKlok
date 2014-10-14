//
//  KlokLayerDelegate.m
//  TerugTelKlok
//
//  Created by J SMAAL on 06-01-12.
//  Copyright (c) 2012 Communicatie VolZin. All rights reserved.
//

#import "KlokLayerDelegate.h"

#define KLOKVIEW_DEBUGGING 1 

@implementation KlokLayerDelegate

@synthesize drawingRect;
@synthesize delegate;
@synthesize radius;


-(id)init
{
	if(self = [super init]){
	}
	return self;
}


-(void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
	// Push
	UIGraphicsPushContext(context);
	drawingRect = layer.bounds;
	
	if(layer.bounds.size.width > layer.bounds.size.height )  {
		// Landscape use height for radius
		radius = drawingRect.size.height/2 - 5;
	}
	else{
		// Portrait use width for radius
		radius = drawingRect.size.width/2 - 5;
	}
	[self drawKlokBackground:context];

	// Ask my delegate what these values are.
	NSDateComponents *huidigeDateComponents = [self.delegate DateComponentsForKlokLayer:self];
	
    // FIXME!!! Could be nill
    NSDateComponents *alarmDateComponents = [self.delegate DateComponentsAlarmTijdForKlokLayer:self];
    
	
	[self drawUrenWijzerContext:context 
							uur:huidigeDateComponents.hour 
						minuten:huidigeDateComponents.minute];

	[self drawMinutenWijzer:context 
					opGetal:huidigeDateComponents.minute];

	// Only draw pieshape if there is a timer running. 
	if([self.delegate TimerRunningForKlokLayer:self]){
		// Only show minutes if alarm is less than one hour away 
		if(![self.delegate NogMeerDanEenUurTeGaanForKlokLayer:self]){
			[self drawPieShapeMinutenInKlok:context 
								 fromCijfer:huidigeDateComponents.minute // vanMin 
								   toCijfer:alarmDateComponents.minute];  // totMin
		}
		
		// Only draw hour shape the hour is different from the current 
		// time. 
		if(huidigeDateComponents.hour != alarmDateComponents.hour){
			[self drawPieShapeUurInKlok:context 
							huidigeTijd:huidigeDateComponents 
							  alarmTijd:alarmDateComponents];
		}
	}
	
#if KLOKVIEW_DEBUGGING
	CGPoint tmpPoint = [self.delegate TapPointForKlokViewLayer:self];
	[KlokLayerDelegate drawMyCircle:context atPoint:tmpPoint];
#endif	
	
	huidigeDateComponents = nil;
	alarmDateComponents = nil;
	
	// PoP
	UIGraphicsPopContext();
}


-(void)drawKlokBackground:(CGContextRef)context
{
	// -- Push --
	UIGraphicsPushContext(context);
	
	
	//CGContextSetRGBFillColor(context, 1,0.2,0.2,1);
	//CGContextFillRect(context, drawingRect);
	
	/* 
	 * Achtergrond cirkel 
	 * 
	 * x = a + r * cos (t) 
	 * y = b + r * sin (t)
	 */
	int a = CGRectGetMidX(drawingRect);
	int b = CGRectGetMidY(drawingRect);
	
	float r = radius * 0.9;
	
	float t_rad = (2.0 * M_PI )/12; 
	CGPoint centre = CGPointMake(a, b);
	
	/* 
	 * BuitenRand van de klok
	 */
	CGContextSetRGBFillColor(context, 0.4,0.4,0.4,1);
	CGContextSetRGBStrokeColor(context, 0,1,0, 1);
	UIBezierPath *randcircle;
	
	randcircle = [UIBezierPath 
				  bezierPathWithArcCenter:CGPointMake(a, b) 
				  radius:radius
				  startAngle:0 
				  endAngle:(2*M_PI)
				  clockwise:YES];
	
	randcircle.lineWidth  = 0;
	randcircle.lineJoinStyle = kCGLineJoinRound;
	randcircle.lineCapStyle = kCGLineCapSquare;
	[randcircle stroke];
	[randcircle fill];
	randcircle = nil;
	
	/*
	 * BinnenRand van de klok
	 */
	CGContextSetRGBFillColor(context, 1,1,1,1);
	CGContextSetRGBStrokeColor(context, 0,0,1, 1);
	randcircle = [UIBezierPath 
				  bezierPathWithArcCenter:CGPointMake(a,b) 
				  radius:(radius * 0.9)
				  startAngle:0 
				  endAngle:(2*M_PI) 
				  clockwise:YES];
	randcircle.lineWidth  = 0;
	randcircle.lineJoinStyle = kCGLineJoinRound;
	randcircle.lineCapStyle = kCGLineCapSquare;
	[randcircle stroke];
	[randcircle fill];
	randcircle = nil;
	
	/*
	 * Nu de cijferplaat
	 */
	CGContextSetRGBFillColor(context, 0.3,0.3,0.3, 0);
	CGContextSetRGBStrokeColor(context, 0,0,0, 0.6);
	UIBezierPath *circle = [UIBezierPath 
							bezierPathWithArcCenter:CGPointMake(a, b) 
							radius:r 
							startAngle:0 
							endAngle:(2*M_PI)
							clockwise:YES];
	circle.lineWidth  = 3;
	circle.lineJoinStyle = kCGLineJoinRound;
	circle.lineCapStyle = kCGLineCapSquare;
	[circle stroke];
	[circle fill];
	circle = nil;
	
	/*
	 * Lijnen en cijfers op de wijzerplaat 
	 */
	CGContextSetRGBStrokeColor(context, 0,0,0,1); 
	UIBezierPath *wijzerplaat = [[UIBezierPath alloc] init];
	wijzerplaat.lineWidth = 10; 
	
	/*
	 * Teken de cijfers en de streepjes 
	 * ------------ 
	 */
	float temp_rad = 0;
	NSString *tmpString; 
	for(int i = 0, j = 3; i < 12; i++, j++){
		CGPoint binnencircumference; 
		CGPoint cijfers;
		CGRect labelRect;
		
		if (i%3) { // kleine lijnen 
			binnencircumference.x = a + (r * 0.9) * cos(temp_rad);
			binnencircumference.y = b + (r * 0.9) * sin(temp_rad);
		} 
		else{ // Grote lijnen 
			binnencircumference.x = a + (r * 0.84) * cos(temp_rad);
			binnencircumference.y = b + (r * 0.84) * sin(temp_rad);
		}
		
		/* 
		 * Cijfer op de plaat 
		 */
		CGContextSetRGBFillColor(context, 0,0,0.5,0.8); 
		labelRect.size = CGSizeMake(radius * 0.15, radius * 0.15);
		cijfers.x =  (a - labelRect.size.width/2)  + (radius * 0.68) * cos(temp_rad);
		cijfers.y =  (b - labelRect.size.height/2)  + (radius * 0.68) * sin(temp_rad);
		labelRect.origin = cijfers;
		
		tmpString = [NSString stringWithFormat:@"%d", j];
		
		// Als j op 12 staat moet de klok later weer met 1 beginnen. 
		if(j == 12) {
			j = 0;
		}
        /*
		[tmpString drawInRect:labelRect 
					 withFont:[UIFont systemFontOfSize:(radius * 0.13)] 
				lineBreakMode:UILineBreakModeMiddleTruncation 
					alignment:UITextAlignmentCenter];
        */
        
        [tmpString drawInRect: labelRect withAttributes:@{}];
        
		tmpString = nil;		
		
		/* 
		 * Wijzerplaat 
		 */	
		CGContextSetRGBFillColor(context, 0,0,0,1); 
		// Reken de plaats uit op de cirkel 
		[wijzerplaat moveToPoint:binnencircumference];
		
		CGPoint circumference; 	
		circumference.x = a + (r + 5) * cos(temp_rad);
		circumference.y = b + (r + 5) * sin(temp_rad);
		[wijzerplaat addLineToPoint:circumference];
		//[wijzerplaat closePath];
		[wijzerplaat stroke];
		[wijzerplaat fill];
		temp_rad = temp_rad + t_rad;
	}
	wijzerplaat = nil;
	
	// Cirkel in het midden
	[KlokLayerDelegate drawMyCircle:context atPoint:centre];

	/* ----------- */ 
	
	// -- Pop --
	UIGraphicsPopContext();	
}



-(void)drawUrenWijzerContext:(CGContextRef)context 
						 uur:(long)uur
					 minuten:(long)minuten
{
	// -- Push --
	UIGraphicsPushContext(context);
	int a = CGRectGetMidX(drawingRect);
	int b = CGRectGetMidY(drawingRect);
		
	float r = radius * 0.45;
	
	// De urenwijzer verplaatst ook per minuut een klein beetje.
	float startAngle = -M_PI/2;
	float t_rad = startAngle + (2.0 * M_PI )/12 * uur;
	t_rad = t_rad + (2.0 * M_PI)/(12*60) * minuten;
	
	
	CGPoint endLine;
	endLine.x = a + r * cos(t_rad);
	endLine.y = b + r * sin(t_rad);
	
	
	CGPoint centre = CGPointMake(a, b);
	
	CGContextSetRGBStrokeColor(context, 0,0,0,1); 
	//CGContextSetRGBFillColor(context, 0,1,0,1); 
	UIBezierPath *minutenwijzer = [[UIBezierPath alloc ] init];
	[minutenwijzer moveToPoint:centre];
	[minutenwijzer addLineToPoint:endLine];
	minutenwijzer.lineWidth = radius * 0.04;
	//[minutenwijzer fill];
	[minutenwijzer stroke];
	minutenwijzer = nil;
	
	// -- Pop --
	UIGraphicsPopContext();	
}





-(void)drawMinutenWijzer:(CGContextRef)context 
				 opGetal:(long)getal
{	
	// -- Push --
	UIGraphicsPushContext(context);	
	int a = CGRectGetMidX(drawingRect);
	int b = CGRectGetMidY(drawingRect);
	
	float r = radius * 0.75;
	float startAngle = -M_PI/2;
	float t_rad = startAngle + (2.0 * M_PI )/60 * getal;
	
	CGPoint endLine;
	endLine.x = a + r * cos(t_rad);
	endLine.y = b + r * sin(t_rad);
	
	
	CGPoint centre = CGPointMake(a, b);
	
	CGContextSetRGBStrokeColor(context, 0.3,0.3,0.3,1); 
	CGContextSetRGBFillColor(context, 0,0,0,0.4); 
	UIBezierPath *minutenwijzer = [[UIBezierPath alloc ] init];
	[minutenwijzer moveToPoint:centre];
	[minutenwijzer addLineToPoint:endLine];
	minutenwijzer.lineWidth = radius * 0.025;
	[minutenwijzer stroke];
	[minutenwijzer fill];
	minutenwijzer = nil;
	
	// -- Pop --
	UIGraphicsPopContext();	
}


// Cijfer is in minuten
-(void)drawPieShapeMinutenInKlok:(CGContextRef)context
			   fromCijfer:(long)fromCijfer
				 toCijfer:(long)toCijfer
{
	// -- Push --
	UIGraphicsPushContext(context);
	int a = CGRectGetMidX(drawingRect);
	int b = CGRectGetMidY(drawingRect);
	
	float r = radius * 0.73;
	
	float startAngle = -M_PI/2;
	float endAngle = -M_PI/2;
	
	float t_rad = (2.0 * M_PI )/60;
	CGPoint centre = CGPointMake(a, b);
	
	// Dit kunnen we niet echt tekenen.... 
	if(fromCijfer == toCijfer){
		startAngle = startAngle + fromCijfer * t_rad;
		endAngle = startAngle + t_rad/5;
		//endAngle = endAngle + toCijfer * t_rad;
	}
	else { // Dit gaat prima. 
		startAngle = startAngle + fromCijfer * t_rad;
		endAngle = endAngle + toCijfer * t_rad;
	}
	
	// Rood
	CGContextSetRGBFillColor(context, 1,0,0,0.4);
	CGContextSetRGBStrokeColor(context, 1,0,0,0.7);
	UIBezierPath *pieshape = [UIBezierPath 
							  bezierPathWithArcCenter:CGPointMake(a, b) 
							  radius:r 
							  startAngle:startAngle 
							  endAngle:endAngle 
							  clockwise:YES];
	// clockwise:(fromCijfer < toCijfer)];
	[pieshape addLineToPoint:centre];
	[pieshape stroke];
	[pieshape fill];
	pieshape = nil;
	
	// -- Pop --
	UIGraphicsPopContext();	
}


// Cijfer is in uur
-(void)drawPieShapeUurInKlok:(CGContextRef)context
	huidigeTijd:(NSDateComponents *)huidigeTijd
	alarmTijd:(NSDateComponents *)alarmTijd
{
	// -- Push --
	UIGraphicsPushContext(context);
	int a = CGRectGetMidX(drawingRect);
	int b = CGRectGetMidY(drawingRect);
	
	float r = radius * 0.4;
	
	float startAngle 	= -M_PI/2;
	float endAngle 		= -M_PI/2;
	
	float t_rad_uur 	= (2.0 * M_PI )/12;
	float t_rad_min 	= (2.0 * M_PI )/(12*60);
	
	
	// De urenwijzer verplaatst ook per minuut een klein beetje.
	// Lastig omdat dit om de huidige tijd gaat.... 
	startAngle = startAngle 
				+ huidigeTijd.hour * t_rad_uur 
				+ huidigeTijd.minute * t_rad_min;

	endAngle = endAngle 
				+ alarmTijd.hour * t_rad_uur 
				+ alarmTijd.minute * t_rad_min;		

	
	CGPoint centre = CGPointMake(a, b);
	
	// Blauw
	CGContextSetRGBFillColor(context, 0,0,1,0.6);
	CGContextSetRGBStrokeColor(context, 0,0,1,0.7);
	
	UIBezierPath *pieshape = [UIBezierPath 
							  bezierPathWithArcCenter:CGPointMake(a, b) 
							  radius:r 
							  startAngle:startAngle 
							  endAngle:endAngle 
							  clockwise:YES];
	// clockwise:(fromCijfer < toCijfer)];
	[pieshape addLineToPoint:centre];
	[pieshape stroke];
	[pieshape fill];
	pieshape = nil;
	
	// -- Pop --
	UIGraphicsPopContext();	
}




+(void)drawMyCircle:(CGContextRef)context 
			atPoint:(CGPoint)atpoint
{
	// -- Push --
	UIGraphicsPushContext(context);
	
	CGContextSetRGBFillColor(context, 1,1,1,1);
	UIBezierPath *circle = [UIBezierPath 
							bezierPathWithArcCenter:atpoint 
							radius:5 
							startAngle:0 
							endAngle:(2*M_PI)
							clockwise:YES];
	circle.lineWidth  = 3;
	circle.lineJoinStyle = kCGLineJoinRound;
	circle.lineCapStyle = kCGLineCapSquare;
	[circle stroke];
	//[circle fill];
	circle = nil;
	
	// -- Pop --
	UIGraphicsPopContext();	
}



@end
