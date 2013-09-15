//
//  FFmpegWrapper.h
//  LiveStreamer
//
//  Created by Christopher Ballinger on 9/14/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FFmpegWrapperCallback)(BOOL success, NSError *error);

@interface FFmpegWrapper : NSThread

@property (nonatomic, strong) FFmpegWrapperCallback completionCallback;
@property (nonatomic, strong) NSString *inputPath;
@property (nonatomic, strong) NSString *outputPath;
@property (nonatomic, strong) NSArray *options;

- (id) initWithInputFileAtPath:(NSString*)inputPath options:(NSArray*)options outputPath:(NSString*)outputPath completionBlock:(FFmpegWrapperCallback)completionCallback;

@end
