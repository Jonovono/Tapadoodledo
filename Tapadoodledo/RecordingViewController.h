//
//  RecordingViewController.h
//  Tapadoodledo
//
//  Created by Jordan Howlett on 14/01/2014.
//  Copyright (c) 2014 Jordan Howlett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordingViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,   AVAudioPlayerDelegate>
- (IBAction)dismissModal:(id)sender;
- (IBAction)enterEditMode:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *recordingsTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButtonRight;

@end
