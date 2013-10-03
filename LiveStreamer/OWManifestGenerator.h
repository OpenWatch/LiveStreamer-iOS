//
//  OWManifestGenerator.h
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/1/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^OWManifestGeneratorCompletionBlock)(BOOL success, NSError *error);

@interface OWManifestGenerator : NSObject

@property (nonatomic, strong) NSString *manifestPath;
@property (nonatomic, strong) NSMutableArray *segments;
@property (nonatomic, strong) NSString *header;
@property (nonatomic) int currentSegmentNumber;
@property (nonatomic) int targetSegmentDuration;

- (id) initWithM3U8Path:(NSString*)path targetSegmentDuration:(int)duration;

- (void) appendSegmentPath:(NSString *)segmentPath duration:(int)duration sequence:(int)sequence completionBlock:(OWManifestGeneratorCompletionBlock)completionBlock;

@end
