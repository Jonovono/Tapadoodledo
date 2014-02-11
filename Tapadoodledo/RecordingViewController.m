//
//  RecordingViewController.m
//  Tapadoodledo
//
//  Created by Jordan Howlett on 14/01/2014.
//  Copyright (c) 2014 Jordan Howlett. All rights reserved.
//

#import "RecordingViewController.h"

@interface RecordingViewController () {
    AVAudioPlayer *player;
}

@end

@implementation RecordingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissModal:(id)sender {
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)enterEditMode:(id)sender {
    [self.recordingsTable setEditing: YES animated: YES];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath_ = [searchPaths objectAtIndex: 0];
    NSString *recordings = @"recordings";
    NSString *filePath2 = [documentPath_
                            stringByAppendingPathComponent:recordings];
    
    return [self countAtPath:filePath2];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath_ = [searchPaths objectAtIndex: 0];

    NSString *recordings = @"recordings";
    NSString *recordingsPath = [documentPath_ stringByAppendingFormat:@"/%@", recordings];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:recordingsPath error:NULL];
    id obj = [directoryContent objectAtIndex:indexPath.row];
    NSString *filestring = [documentPath_ stringByAppendingFormat:@"/%@/%@",recordings, obj];
    
    NSDictionary *filePathsArray1 = [[NSFileManager defaultManager] attributesOfItemAtPath:filestring error:nil];
    NSString *createdDate = [filePathsArray1 objectForKey:NSFileModificationDate];
    
    static NSString *CellIdentifier = @"MyStaticCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",createdDate];
//        cell.textLabel.text = [NSString stringWithFormat:@"%@",obj];
    return cell;
}


- (NSUInteger *)countAtPath:(NSString *)path {
    NSArray *directoryContent  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];

    return [directoryContent count];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // now you can use cell.textLabel.text
    [self playRecording:indexPath.row];
}

- (void)playRecording:(NSUInteger *)num {
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath_ = [searchPaths objectAtIndex: 0];

    NSString *recordings = @"recordings";
    NSString *recordingsPath = [documentPath_ stringByAppendingFormat:@"/%@", recordings];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:recordingsPath error:NULL];
    id obj = [directoryContent objectAtIndex:num];
    NSString *filestring = [documentPath_ stringByAppendingFormat:@"/%@/%@",recordings, obj];

    NSURL *url = [NSURL fileURLWithPath:filestring];//FILEPATH];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player setDelegate:self];
    [player play];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath_ = [searchPaths objectAtIndex: 0];

        NSString *recordings = @"recordings";
        NSString *filestring = [documentPath_ stringByAppendingFormat:@"/%@",recordings];
        NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filestring error:NULL];
        id obj = [directoryContent objectAtIndex:indexPath.row];
        NSString *theFile = [filestring stringByAppendingFormat:@"/%@",obj];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:theFile error:NULL];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// The editButtonItem will invoke this method.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.recordingsTable setEditing:editing animated:animated];
    
    if (editing) {
        // Execute tasks for editing status
    } else {
        // Execute tasks for non-editing status.
    }
}

@end
