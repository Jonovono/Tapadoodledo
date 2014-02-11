//
//  AppDelegate.m
//  Tapadoodledo
//
//  Created by Jordan Howlett on 24/12/2013.
//  Copyright (c) 2013 Jordan Howlett. All rights reserved.
//

#import "AppDelegate.h"

#import <AudioToolbox/AudioServices.h>

UIBackgroundTaskIdentifier bgTask;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startFetchingLocationsContinously) name:START_FETCH_LOCATION object:nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"firstLaunch",nil]];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

//    [[NSNotificationCenter defaultCenter] postNotificationName:START_FETCH_LOCATION object:nil];
    
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    [appDelegate startUpdatingDataBase];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    NSLog(@"SUPPORT BG");
//    NSTimer *noCloseSpikesTimer = [[NSTimer alloc] init];
//    noCloseSpikesTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        // Do the work associated with the task, preferably in chunks.
//        NSLog(@"test");
//    });
    
//    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{ [self backgroundHandler]; }];
//    if (backgroundAccepted)
//    {
//        NSLog(@"VOIP backgrounding accepted");
//    }
//    
//    UIApplication*    app = [UIApplication sharedApplication];
//    
//    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
//        [app endBackgroundTask:bgTask];
//        bgTask = UIBackgroundTaskInvalid;
//    }];
//    
//    
//    // Start the long-running task
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        while (1) {
//            NSLog(@"BGTime left: %f", [UIApplication sharedApplication].backgroundTimeRemaining);
//            sleep(1);
//        }    
//    });

    
//    UIApplication*    app = [UIApplication sharedApplication];
//    
//    // it's better to move "dispatch_block_t expirationHandler"
//    // into your headerfile and initialize the code somewhere else
//    // i.e.
//    // - (void)applicationDidFinishLaunching:(UIApplication *)application {
//    //
//    // expirationHandler = ^{ ... } }
//    // because your app may crash if you initialize expirationHandler twice.
//    dispatch_block_t expirationHandler;
//    expirationHandler = ^{
//        
//        [app endBackgroundTask:bgTask];
//        bgTask = UIBackgroundTaskInvalid;
//        
//        
//        bgTask = [app beginBackgroundTaskWithExpirationHandler:expirationHandler];
//    };
//    
//    bgTask = [app beginBackgroundTaskWithExpirationHandler:expirationHandler];
//    
//    
//    // Start the long-running task and return immediately.
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        // inform others to stop tasks, if you like
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyApplicationEntersBackground" object:self];
//        
//        // do your background work here     
//    }); 

    
    //CLLocationManager *locationManager = [[CLLocationManager alloc] init];
//    locationManager.delegate = self;//or whatever class you have for managing location
  //  [locationManager startUpdatingLocation];
//    NSTimer *timer = [[NSTimer alloc] init];
//    timer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];


    
//    UIApplication *app = [UIApplication sharedApplication];
//    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
//    
//    bgTask2 = [app beginBackgroundTaskWithExpirationHandler:^{ [app endBackgroundTask:bgTask2]; bgTask2 = UIBackgroundTaskInvalid; }];
//    
//    locationManager.delegate = self;
//    [locationManager startUpdatingLocation];

//    UIApplication* app = [UIApplication sharedApplication];
//    
//    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
//        [app endBackgroundTask:bgTask];
//        bgTask = UIBackgroundTaskInvalid;
//    }];
//    
//    NSTimer *timer = [[NSTimer alloc] init];
//    timer = [NSTimer scheduledTimerWithTimeInterval:intervalBackgroundUpdate
//                                                  target:self.locationManager
//                                                selector:@selector(startUpdatingLocation)
//                                                userInfo:nil
//                                                 repeats:YES];
}

-(void)didUpdateToLocation:(CLLocation*)location {

}

- (void)timerTick:(NSTimer *)timer1
{
    
}

//- (void)backgroundHandler {
//    
//    NSLog(@"### -->VOIP backgrounding callback");
//    
//    UIApplication*    app = [UIApplication sharedApplication];
//    
//    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
//        [app endBackgroundTask:bgTask];
//        bgTask = UIBackgroundTaskInvalid;
//    }];
//    
//    // Start the long-running task
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        while (1) {
//            NSLog(@"BGTime left: %f", [UIApplication sharedApplication].backgroundTimeRemaining);
//            sleep(1);
//        }   
//    });
//}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"audio"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"phone"];
}

//#pragma mark - Location Update
//-(void)startFetchingLocationsContinously{
//    NSLog(@"start Fetching Locations");
//    self.locationUtil = [[LocationUtil alloc] init];
//    [self.locationUtil setDelegate:self];
//    [self.locationUtil startLocationManager];
//}
//
//-(void)locationRecievedSuccesfullyWithNewLocation:(CLLocation*)newLocation oldLocation:(CLLocation*)oldLocation{
//    NSLog(@"location received successfullly in app delegate for Laitude: %f and Longitude:%f, and Altitude:%f, and Vertical Accuracy: %f",newLocation.coordinate.latitude,newLocation.coordinate.longitude,newLocation.altitude,newLocation.verticalAccuracy);
//}
//
//-(void)startUpdatingDataBase{
//    UIApplication*    app = [UIApplication sharedApplication];
//    
//    bgTask = UIBackgroundTaskInvalid;
//    
//    bgTask = [app beginBackgroundTaskWithExpirationHandler:^(void){
//        [app endBackgroundTask:bgTask];
//    }];
//    
//    SAVE_LOCATION_TIMER =  [NSTimer scheduledTimerWithTimeInterval:300
//                                                            target:self selector:@selector(startFetchingLocationsContinously) userInfo:nil repeats:YES];
//}

@end
