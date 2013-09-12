//
//  OWRootViewController.m
//  LiveStreamer
//
//  Created by Christopher Ballinger on 9/11/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import "OWRootViewController.h"
#import "OWCaptureViewController.h"

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
    OWCaptureViewController *captureViewController = [[OWCaptureViewController alloc] init];
    captureViewController.delegate = self;
    [self presentViewController:captureViewController animated:YES completion:nil];
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
