//
//  OWUtilities.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/29/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWUtilities : NSObject

+ (CGFloat) bottomOfView:(UIView*)view;
+ (CGFloat) rightOfView:(UIView*)view;
+ (NSURL*) urlForRecordingSegmentCount:(NSUInteger)count basePath:(NSString*)basePath;
+ (NSString*) applicationDocumentsDirectory;

@end
