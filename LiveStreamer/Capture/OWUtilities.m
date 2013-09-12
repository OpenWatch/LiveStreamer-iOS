//
//  OWUtilities.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/29/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWUtilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation OWUtilities

+ (CGFloat) bottomOfView:(UIView *)view {
    return view.frame.origin.y + view.frame.size.height;
}

+ (CGFloat) rightOfView:(UIView *)view {
    return view.frame.origin.x + view.frame.size.width;
}

+ (NSURL*) urlForRecordingSegmentCount:(NSUInteger)count basePath:(NSString*)basePath {
    NSString *movieName = [NSString stringWithFormat:@"%d.mp4", count+1];
    NSString *path = [basePath stringByAppendingPathComponent:movieName];
    NSURL *newMovieURL = [NSURL fileURLWithPath:path];
    return newMovieURL;
}

+ (NSString*) applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
