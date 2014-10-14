//
//  AppDelegate.m
//  TerugTelKlok
//
//  Created by J SMAAL on 27-12-11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

@synthesize klokmodel;
@synthesize huidigetijdmodel;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	
	// Er is maar een klok en hier wordt deze aangemaakt. 
	klokmodel = [TerugTelTimerModel SingletonKlokModel];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
	
	// Haal oude notifications weg.  
	UIApplication *app = [ UIApplication sharedApplication];
	
	NSArray *scheduled = [app scheduledLocalNotifications];
	if(scheduled.count){
		[app cancelAllLocalNotifications];
	}
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	SystemSoundID systemsound;
	
	// Als er lokaal een notification binnen komt. 
#if DEBUG
	//NSLog(@"Local notification!!!");
#endif
	NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"alarm" 
														  ofType:@"caf"];
	NSURL *soundURL = [NSURL fileURLWithPath:soundFile];
	AudioServicesCreateSystemSoundID( (__bridge CFURLRef) soundURL, &systemsound);
	AudioServicesPlaySystemSound(systemsound);
	// Dispose this variable. 
	if(systemsound){
		//	AudioServicesDisposeSystemSoundID(systemsound);
	}
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
	
	// Dit doen we nu vanuit FlipsideViewController ! 
	if([klokmodel running]){
		UIApplication *app = [ UIApplication sharedApplication];
		
		// Haal oude notifications weg. 
		NSArray *scheduled = [app scheduledLocalNotifications];
		if(scheduled.count){
			[app cancelAllLocalNotifications];
		}
		UILocalNotification *alarm = [[UILocalNotification alloc] init];
		if(alarm){
			alarm.fireDate = klokmodel.alarmTijd;
			alarm.timeZone = [NSTimeZone defaultTimeZone];
			alarm.repeatInterval = 0;
			alarm.alertBody = @"Alarm";
			alarm.alertAction = nil;
			alarm.soundName = @"alarm.caf";
			[app scheduleLocalNotification:alarm];
		}
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
	
#if 0
	// Haal oude notifications weg. 
	UIApplication *app = [ UIApplication sharedApplication];
	
	NSArray *scheduled = [app scheduledLocalNotifications];
	if(scheduled.count){
		[app cancelAllLocalNotifications];
	}
#endif 
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}


// Not Called! 
- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */

}

@end