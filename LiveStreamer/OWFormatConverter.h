//
//  OWFormatConverter.h
//  LiveStreamer
//
//  Created by Christopher Ballinger on 9/12/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^OWFormatConverterCallback)(NSString *outputPath, NSError *error);

@interface OWFormatConverter : NSObject

- (void) convertFileAtPath:(NSString*)inputPath outputPath:(NSString*)outputPath completionBlock:(OWFormatConverterCallback)completionCallback;

+ (OWFormatConverter *)sharedInstance;

@end
