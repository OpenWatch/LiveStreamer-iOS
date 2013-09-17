//
//  OWRootViewController.m
//  LiveStreamer
//
//  Created by Christopher Ballinger on 9/11/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import "OWRootViewController.h"
#import "OWCaptureViewController.h"
#import "OWUtilities.h"
#import "FFmpegWrapper.h"

@interface OWRootViewController ()

@end

@implementation OWRootViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.testButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.testButton setTitle:@"Start Test" forState:UIControlStateNormal];
        [self.testButton addTarget:self action:@selector(testButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.testButton];
    }
    return self;
}

- (void) testButtonPressed:(id)sender {
    NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"mp4" inDirectory:@"web"];
    NSString *basePath = [OWUtilities applicationDocumentsDirectory];
    NSString *outputFile = [basePath stringByAppendingPathComponent:@"test.ts"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:outputFile]) {
        [fileManager removeItemAtPath:outputFile error:nil];
    }
    NSDictionary *options = @{kFFmpegOutputFormatKey: @"mp4"};

    [paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
        NSLog(@"path %d: %@", idx, path);
        [FFmpegWrapper convertInputPath:path outputPath:outputFile options:options progressBlock:^(double progress) {
            NSLog(@"progress: %f", progress);
        } completionBlock:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"success!");
            } else {
                NSLog(@"error: %@", error.userInfo);
            }
        }];
        *stop = YES;
    }];
    

    /*
    OWCaptureViewController *captureViewController = [[OWCaptureViewController alloc] init];
    captureViewController.delegate = self;
    [self presentViewController:captureViewController animated:YES completion:nil];
     */
}


- (void) captureViewControllerDidCancel:(OWCaptureViewController *)captureViewController {
    [captureViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) captureViewControllerDidFinishRecording:(OWCaptureViewController *)captureViewController {
    [captureViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    self.testButton.frame = CGRectMake(50, 50, 100, 50);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
