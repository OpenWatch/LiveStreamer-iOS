//
//  FFmpegWrapper.m
//  LiveStreamer
//
//  Created by Christopher Ballinger on 9/14/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import "FFmpegWrapper.h"
#import "ffmpeg.h"
#import "cmdutils.h"

@implementation FFmpegWrapper
@synthesize completionCallback, inputPath, outputPath, options;

- (id) initWithInputFileAtPath:(NSString*)newInputPath options:(NSArray*)newOptions outputPath:(NSString*)newOutputPath completionBlock:(FFmpegWrapperCallback)newCompletionCallback {
    if (self = [super init]) {
        self.completionCallback = newCompletionCallback;
        self.inputPath = newInputPath;
        self.outputPath = newOutputPath;
        self.options = newOptions;
    }
    return self;
}

- (void) main {
    //simulating ffmpeg -i input.mp4 -f mpegts -vcodec copy -acodec copy -vbsf h264_mp4toannexb output.ts
    
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:4+[options count]];
    [arguments addObject:@"ffmpeg"];
    [arguments addObject:@"-i"];
    [arguments addObject:inputPath];
    [arguments addObjectsFromArray:options];
    [arguments addObject:outputPath];
    
    int argc = [arguments count];
    char **argv = malloc(sizeof(char*) * (argc + 1));
    
    [arguments enumerateObjectsUsingBlock:^(NSString *option, NSUInteger i, BOOL *stop) {
        const char * c_string = [option UTF8String];
        int length = strlen(c_string);
        char *c_string_copy = (char *) malloc(sizeof(char) * (length + 1));
        strcpy(c_string_copy, c_string);
        argv[i] = c_string_copy;
    }];
    argv[argc] = NULL;
    
    int returnValue = ffmpeg_main(argc, argv);
    free(argv);
    NSLog(@"ffmpeg return value: %d", returnValue);
    if (completionCallback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (returnValue == 0) {
                completionCallback(YES, nil);
            }  else {
                completionCallback(NO, [NSError errorWithDomain:@"org.ffmpeg.ffmpeg" code:returnValue userInfo:nil]);
            }
        });
    }
}

@end
