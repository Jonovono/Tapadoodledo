//
//  ViewController.h
//  Tapadoodledo
//
//  Created by Jordan Howlett on 24/12/2013.
//  Copyright (c) 2013 Jordan Howlett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController : UIViewController <AVAudioRecorderDelegate,
                                              AVAudioPlayerDelegate,
                                              UIAccelerometerDelegate>

// For accelerometer
@property (strong, nonatomic) CMMotionManager *motionManager;

// For location, which we need to run in the background.
@property (nonatomic, retain) CLLocationManager *locationMgr;

// Switch to start listening or not.
@property (weak, nonatomic) IBOutlet UISwitch *recordAudioSwitch;
// @property (weak, nonatomic) IBOutlet UISwitch *fakeCallSwitch;

// For showing the time running while recording
@property (strong, nonatomic) NSDate *startDate;

// Button to start/stop recording
@property (weak, nonatomic) IBOutlet UIButton *recordingIndicatorButton;

// Label for how long been recording
@property (weak, nonatomic) IBOutlet UILabel *timeRecordingLabel;
@property (weak, nonatomic) IBOutlet UIView *recordButtonView;
@property (weak, nonatomic) IBOutlet UIView *stateView;
@property (weak, nonatomic) IBOutlet UILabel *stateMessage;

// Called when slider to start listening pressed
- (IBAction)recordAudioCalled:(id)sender;
//- (IBAction)fakeCallCalled:(id)sender;

// Button to start/stop recording
- (IBAction)recordStopAction:(id)sender;

@end


