//
//  OWManifestGenerator.m
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/1/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import "OWManifestGenerator.h"

@implementation OWManifestGenerator
@synthesize manifestPath, segments, header;

- (NSString*) lineForFileName:(NSString*)fileName duration:(int)duration {
    return [NSString stringWithFormat:@"#EXTINF:%d,\n%@\n", duration, fileName];
}

- (id) initWithM3U8Path:(NSString*)path targetSegmentDuration:(int)duration {
    if (self = [super init]) {
        self.currentSegmentNumber = -1;
        self.manifestPath = path;
        self.targetSegmentDuration = duration;
        self.header = [NSString stringWithFormat:@"#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-ALLOW-CACHE:NO\n#EXT-X-TARGETDURATION:%d\n", duration];
//#EXT-X-MEDIA-SEQUENCE:25755\n#EXTINF:11,\nmedia_25756.ts?wowzasessionid=2003983250\n#EXTINF:9,\nmedia_25757.ts?wowzasessionid=2003983250";
        self.segments = [NSMutableArray array];
    }
    return self;
}

- (void) appendSegmentPath:(NSString *)segmentPath duration:(int)duration sequence:(int)sequence {
    [self.segments addObject:segmentPath];
    
    NSMutableArray *lastSegments = [NSMutableArray arrayWithCapacity:3];
    
    if (segments.count <= 3) {
        [lastSegments addObjectsFromArray:segments];
    } else {
        int thirdToLastSegmentIndex = segments.count - 3;
        for (int i = 0; i < 3; i++) {
            [lastSegments addObject:[segments objectAtIndex:thirdToLastSegmentIndex + i - 1]];
        }
    }
    
    NSString *firstFileName = [[lastSegments objectAtIndex:0] lastPathComponent];
    NSString *mediaSequence = [NSString stringWithFormat:@"#EXT-X-MEDIA-SEQUENCE:%@\n", [firstFileName stringByDeletingPathExtension]];
    
    NSMutableString *manifestFileString = [NSMutableString stringWithString:header];
    [manifestFileString appendString:mediaSequence];
    
    for (int i = 0; i < lastSegments.count; i++) {
        NSString *fileName = [[lastSegments objectAtIndex:i] lastPathComponent];
        
        [manifestFileString appendString:[self lineForFileName:fileName duration:duration]];
    }
    NSError *error = nil;
    NSLog(@"Manifest:\n%@\n", manifestFileString);
    [manifestFileString writeToFile:manifestPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error writing manifest file: %@", error.userInfo);
    }
}

@end
