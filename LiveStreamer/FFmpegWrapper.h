//
//  FFmpegWrapper.h
//  FFmpegWrapper
//
//  Created by Christopher Ballinger on 9/14/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//
//  This file is part of FFmpegWrapper.
//
//  FFmpegWrapper is free software; you can redistribute it and/or
//  modify it under the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either
//  version 2.1 of the License, or (at your option) any later version.
//  
//  FFmpegWrapper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public
//  License along with FFmpegWrapper; if not, write to the Free Software
//  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
//

#import <Foundation/Foundation.h>

///-------------------------------------------------
/// @name Callbacks
///-------------------------------------------------

/**
 This callback is called when a job has finished or has failed. Always called on the main queue.
 @param success Whether or not the job was successful.
 @param error If the job was not successful, there might be an error in here.
 */
typedef void(^FFmpegWrapperCompletionBlock)(BOOL success, NSError *error);

/**
 This callback periodically reports on the progress of the job. Always called on the main queue. **Currently unused!**
 @param progress The estimated progress until the current job is complete, valid values range from [0.0, 1.0].
 */
typedef void(^FFmpegWrapperProgressBlock)(double progress);

///-------------------------------------------------
/// @name Options
///-------------------------------------------------

/**
 This controls the type of container for the output format. Accepts NSString values like @"mp4", @"avi", @"mpegts". For a full list of supported formats please consult `$ ffmpeg -formats`.
 */
static NSString *kFFmpegOutputFormatKey = @"kFFmpegOutputFormatKey";

@interface FFmpegWrapper : NSObject

///-------------------------------------------------
/// @name Conversion
///-------------------------------------------------

/**
 Converts file at `inputPath` to a new file at `outputPath` using the parameters specified in the `options` dictionary. The two optional callbacks are for monitoring the progress and completion of a queued task and are always called on the main thread. All calls to this function are currently queued in a synchronous internal dispatch queue.
 
 @param inputPath Full path to the input file.
 @param outputPath Full path to output file.
 @param options Dictionary of key value pairs for settings.
 @param progressBlock Always called on main queue.
 @param completionblock Always called on main queue.
 */
+ (void) convertInputPath:(NSString*)inputPath outputPath:(NSString*)outputPath options:(NSDictionary*)options progressBlock:(FFmpegWrapperProgressBlock)progressBlock completionBlock:(FFmpegWrapperCompletionBlock)completionBlock;

@end
