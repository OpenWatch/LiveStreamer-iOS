//
//  FFmpegWrapper.h
//  LiveStreamer
//
//  Created by Christopher Ballinger on 9/14/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FFmpegWrapperCallback)(BOOL success, NSError *error);

@interface FFmpegWrapper : NSObject

+ (FFmpegWrapper *)sharedInstance;

- (void) convertInputPath:(NSString*)inputPath outputPath:(NSString*)outputPath options:(NSArray*)options completionBlock:(FFmpegWrapperCallback)completionCallback;

@end
