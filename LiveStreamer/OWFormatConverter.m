//
//  OWFormatConverter.m
//  LiveStreamer
//
//  Created by Christopher Ballinger on 9/12/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

/* Parts of this code adapted from demuxing.c from ffmpeg example
 * Copyright (c) 2012 Stefano Sabatini
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#import "OWFormatConverter.h"
#import "ffmpeg.h"

@interface OWFormatConverter()
@end

@implementation OWFormatConverter

- (id) init {
    if (self = [super init]) {
    }
    return self;
}

- (void) convertFileAtPath:(NSString*)inputPath outputPath:(NSString*)outputPath completionBlock:(OWFormatConverterCallback)completionCallback {
    //ffmpeg -i input.mp4 -f mpegts -vcodec copy -acodec copy -vbsf h264_mp4toannexb output.ts

    NSArray *options = @[@"-i", inputPath, @"-f", @"mpegts", @"-vcodec", @"copy", @"-acodec", @"copy", @"-vbsf", @"h264_mp4toannexb", outputPath];
    int argc = [options count];
    char **argv = malloc(sizeof(char*) * argc);
    
    [options enumerateObjectsUsingBlock:^(NSString *option, NSUInteger i, BOOL *stop) {
        argv[i] = (char*)[option UTF8String];
    }];
    
    int returnValue = fake_main(argc, argv);
    NSLog(@"ffmpeg return value: %d", returnValue);
    free(argv);
}

@end
