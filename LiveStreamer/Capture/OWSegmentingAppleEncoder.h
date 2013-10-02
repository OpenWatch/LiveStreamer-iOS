//
//  OWSegmentingAppleEncoder.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWAppleEncoder.h"
#import "OWManifestGenerator.h"
#import "FFmpegWrapper.h"

@interface OWSegmentingAppleEncoder : OWAppleEncoder {
    dispatch_queue_t segmentingQueue;
    NSTimeInterval segmentationInterval;
}

@property (nonatomic, strong) FFmpegWrapper *ffmpegWrapper;
@property (nonatomic, strong) OWManifestGenerator *manifestGenerator;
@property (atomic, retain) AVAssetWriter *queuedAssetWriter;
@property (atomic, retain) AVAssetWriterInput *queuedAudioEncoder;
@property (atomic, retain) AVAssetWriterInput *queuedVideoEncoder;
@property (atomic) BOOL shouldBeRecording;
@property (atomic) NSUInteger segmentCount;
@property (nonatomic, strong) NSString *basePath;

@property (atomic) int videoBPS; // bits/sec
@property (atomic) int audioBPS; // bits/sec

@property (atomic, retain) NSTimer *segmentationTimer;

- (id) initWithBasePath:(NSString*)basePath segmentationInterval:(NSTimeInterval)timeInterval;

@end
