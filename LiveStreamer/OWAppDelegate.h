//
//  OWAppDelegate.h
//  LiveStreamer
//
//  Created by Christopher Ballinger on 9/11/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTTPServer;

#define OW_APP_DELEGATE ((OWAppDelegate*)[UIApplication sharedApplication].delegate)

@interface OWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL forceLandscapeRight;

@end
