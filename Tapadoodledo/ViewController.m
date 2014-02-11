//
//  ViewController.m
//  Tapadoodledo
//
//  Created by Jordan Howlett on 24/12/2013.
//  Copyright (c) 2013 Jordan Howlett. All rights reserved.
//

//Not listening = grey (Inactive)
//Listening but not recording = Green (Listening)
//Recording = Red (Recording)

#import "ViewController.h"

#define kUpdateFrequency	60.0
#define kFilteringFactor    0.4

@interface ViewController () {
    BOOL listening;             // Is app currently listening or not.
    BOOL recording;
    
    BOOL hit;                   // If spike high enough we have a hit
    BOOL first;                 // The first hit or a successive one.
    int count;                  // Count of hits.
    
    NSTimer *noCloseSpikesTimer;    // Timer for time between the hits
    NSTimer *timeRecording;         // How long recording for
    NSTimer *longTimer;             // Longer timer for how many hits detected.
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
    // Some values for detecting the taps
    float prevAccelerationX;
    float prevAccelerationY;
    float prevAccelerationZ;
    
    float prevJerkX;
    float prevJerkY;
    float prevJerkZ;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Creates recording directory if it does not already exist.
    [self createRecordingDirectory];

    // Init values for detecting taps /////////////////////////////////////////////////////////////
    prevAccelerationX = 0;
    prevAccelerationY = 0;
    prevAccelerationZ = 0;
    
    prevJerkX = 0;
    prevJerkY = 0;
    prevJerkZ = 0;
    
    hit = NO;
    first = YES;
    count = 0;
    
    noCloseSpikesTimer = [[NSTimer alloc] init];
    longTimer = [[NSTimer alloc] init];
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    if (!self.motionManager.isDeviceMotionAvailable) {
        NSLog(@"Dont have it");
        exit(1);
    }

    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Get user defaults (what to record?)
    self->listening = [[NSUserDefaults standardUserDefaults] boolForKey:@"audio"];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setActive:YES error:nil];
    
    // Start recording
    [self setupRecording];

    
    //    If have not set listening in prefs, start it as not listening.
    if (self->listening == NULL) {
        [userDefaults setBool:NO forKey:@"audio"];
        [userDefaults synchronize];
        self->listening = NO;
        [self setInactive];
    } else {
    
        // else read if it's listening or not.
        if (self->listening) {
            [self setListening];
        } else {
            [self setInactive];
        }
    }
    
    // Update the value of the switch.
    [self.recordAudioSwitch setOn:self->listening];
    
    // If we are listening start the accelerometer
    if (self->listening) {
        [self startAccelerometer];
    }
}

- (void)startAccelerometer {
    self.locationMgr = [[CLLocationManager alloc] init];
    self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationMgr.delegate = self;
    [self.locationMgr startUpdatingLocation];
    
    self.motionManager.accelerometerUpdateInterval = 1.0 / kUpdateFrequency;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
}

- (void)stopAccelerometer {
    [self.motionManager stopAccelerometerUpdates];
}

- (void)setInactive {
    self.stateView.backgroundColor = [UIColor grayColor];
    self.stateMessage.text = @"Inactive";
    [self.locationMgr stopUpdatingLocation];
    [self stopAccelerometer];
    self->recording = NO;
}

- (void)setListening {
    self.stateView.backgroundColor = [UIColor greenColor];
    self.stateMessage.text = @"Listening";
    [self startAccelerometer];
    self->recording = NO;
}

- (void)setRecording {
    self.stateView.backgroundColor = [UIColor redColor];
    self.stateMessage.text = @"Recording";
    self->recording = YES;
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    float pax = prevAccelerationX;
    float pay = prevAccelerationY;
    float paz = prevAccelerationZ;
    
    float pjx = prevJerkX;
    float pjy = prevJerkY;
    float pjz = prevJerkZ;
    
    prevAccelerationX = acceleration.x - ( (acceleration.x * kFilteringFactor) +
                                          (prevAccelerationX * (1.0 - kFilteringFactor)) );
    prevAccelerationY = acceleration.y - ( (acceleration.y * kFilteringFactor) +
                                          (prevAccelerationY * (1.0 - kFilteringFactor)) );
    prevAccelerationZ = acceleration.z - ( (acceleration.z * kFilteringFactor) +
                                          (prevAccelerationZ * (1.0 - kFilteringFactor)) );
    
    // Compute the derivative (which represents change in acceleration).
    float jerkX = ABS((prevAccelerationX - pax));
    float jerkY = ABS((prevAccelerationY - pay));
    float jerkZ = ABS((prevAccelerationZ - paz));
    
    prevJerkX = jerkX;
    prevJerkY = jerkY;
    prevJerkZ = jerkZ;
    
    // Compute the derivative (which represents change in acceleration).
    float jounceX = ABS((prevJerkX - pjx));
    float jounceY = ABS((prevJerkY - pjy));
    float jounceZ = ABS((prevJerkZ - pjz));

    
    
    if (jerkZ > 1.0 && !hit) {
        count++;
        hit = YES;
        noCloseSpikesTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(closeSpikes:) userInfo:nil repeats:NO];
        if (first) {
            longTimer = [NSTimer scheduledTimerWithTimeInterval:1.8 target:self selector:@selector(longTimer:) userInfo:nil repeats:NO];
            first = NO;
        }
    }
}

- (void)closeSpikes:(NSTimer *)timer1
{
    NSLog(@"RESET");
    hit = NO;
}

- (void)longTimer:(NSTimer *)timer1
{
    if (count >= 2) {
        if (self->recording) {
//            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//            [self localNotification];
            [self stopRecording];
            [self localNotification];
//            [self localNotificationDoneRecording];
        } else {
//            [self localNotification];
//            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//            [self record];
//                        [self localNotification];

            [self localNotification];
            double delayInSeconds = 0.2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self record];

            });


//            [self localNotificationRecording];
        }
    }
    first = YES;
    count = 0;
}

- (void)localNotification {

//    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = [NSString stringWithFormat:@"Tapadoodledo is now recording."];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
////    localNotif.soundName = @"sound1.caf";
    localNotif.applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

- (void)localNotificationRecording {
//    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = [NSString stringWithFormat:@"Tapadoodledo is now recording."];
//    localNotif.soundName = UILocalNotificationDefaultSoundName;
//    localNotif.soundName = @"sound1.caf";
    localNotif.applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];

}


- (void)localNotificationDoneRecording {
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = [NSString stringWithFormat:@"Tapadoodledo is done recording."];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    //    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
}

- (IBAction)recordStopAction:(id)sender {
    // If currently recording
    if (self->recording) {
        [self stopRecording];
    }
    // Not currently recording
    else {
        [self record];
    }

}


- (void)record {
    self.startDate = [NSDate date];
    self->timeRecording = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
    [self.recordingIndicatorButton setTitle:@"Stop recording" forState:UIControlStateNormal];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setActive:YES error:nil];
    
    // Start recording
//    [self setupRecording2];
//    [recorder record];
    [recorder record];
    NSTimer *TimerUpdate = [NSTimer scheduledTimerWithTimeInterval:.1
                                                            target:self selector:@selector(timerTask) userInfo:nil repeats:NO];
    [self setRecording];

}

- (void)stopRecording {
    [self.recordingIndicatorButton setTitle:@"Record" forState:UIControlStateNormal];
    [self->timeRecording invalidate];
    [longTimer invalidate];
    self.timeRecordingLabel.text = @   "";
    
    // Stop recording
    [recorder stop];
    
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setActive:NO error:nil];
    [self moveRecordingToCorrectTime];
    [self setListening];
}



- (void)setupRecording {
    //////////////// GET AUDIO STUFF SET UP ///////////////////////
    // Set the audio file
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath_ = [searchPaths objectAtIndex: 0];
    
        NSString *pathToSave = [documentPath_ stringByAppendingPathComponent:@"TEMP.m4a"];
    // File URL
    NSURL *url = [NSURL fileURLWithPath:pathToSave];//FILEPATH];
    
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:nil];
    recorder.delegate = self;
    
    [recorder prepareToRecord];
    
    recorder.meteringEnabled = YES;
    //////////////////////////////////////////////////////////////////////////////////////////////
}


- (void) timerTask {
    [recorder updateMeters];
    float level = [recorder peakPowerForChannel:-160];
}

- (void)updateTimer:(NSTimer *)timer1
{
    // Create date from the elapsed time
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    // Create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    // Format the elapsed time and set it to the label
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    self.timeRecordingLabel.text = timeString;
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
//    [self.locationMgr stopUpdatingLocation];
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)recordAudioCalled:(id)sender {
    BOOL audioIsOn = [sender isOn];
    
    if (audioIsOn) {
        self.recordButtonView.hidden = NO;
        [self setListening];
    } else {
        self.recordButtonView.hidden = YES;
        [self setInactive];
    }
    
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:audioIsOn forKey:@"audio"];
    [userDefaults synchronize];
    self->listening = audioIsOn;
}

// Returns a string containing the current date.
- (NSString *) dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"ddMMMYYhhmmssa";

//    return [formatter stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%@.m4a", [formatter stringFromDate:[NSDate date]]];
}

// Creates the /recordings directory if it does not already exist.
- (void) createRecordingDirectory {
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath_ = [searchPaths objectAtIndex: 0];
    
    NSString *recordings = @"/recordings";
    NSString *filePath2 = [documentPath_
                            stringByAppendingPathComponent:recordings];
    
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath2
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
    }
}


// Moves the temp recording to the recordings directory.
- (void)moveRecordingToCorrectTime {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath_ = [searchPaths objectAtIndex: 0];
    
    NSString *pathToMove = [documentPath_ stringByAppendingPathComponent:@"TEMP.m4a"];
    NSString *recordings = @"/recordings";
    NSString *filePath2 = [[documentPath_
                            stringByAppendingPathComponent:recordings]
                           stringByAppendingPathComponent:[self dateString]];
    
    
    // Attempt the move
    NSError *error = nil;
    if ([fileMgr copyItemAtPath:pathToMove toPath:filePath2 error:&error] != YES)
        NSLog(@"Unable to move file: %@", [error localizedDescription]);
}

@end


//Stuff for fake phone call:

//- (IBAction)fakeCallCalled:(id)sender {
//    BOOL phoneIsOn = [sender isOn];
//    
//    NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ringtone" ofType:@"mp3"]];
//    self.click = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:nil];
//    [self.click setVolume:1.0];
//    [self.click play];
//    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setBool:phoneIsOn forKey:@"phone"];
//    [userDefaults synchronize];
//    self->phone = phoneIsOn;
//    
//}
