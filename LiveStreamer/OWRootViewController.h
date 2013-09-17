//
//  OWRootViewController.h
//  LiveStreamer
//
//  Created by Christopher Ballinger on 9/11/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWCaptureViewController.h"
#import "FFmpegWrapper.h"

@interface OWRootViewController : UIViewController <OWCaptureDelegate>

@property (nonatomic, strong) UIButton *testButton;
@property (nonatomic, strong) FFmpegWrapper *wrapper;

@end
