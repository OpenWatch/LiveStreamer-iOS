//
//  OWS3Client.m
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/3/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import "OWAFS3Client.h"
#import "OWSecrets.h"
#import "AFKissXMLRequestOperation.h"

#define BUCKET_NAME @"openwatch-livestreamer"

@implementation OWAFS3Client

+ (OWAFS3Client *)sharedClient {
    static OWAFS3Client *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[OWAFS3Client alloc] init];
    });
    return _sharedInstance;
}

- (id) init {
    if (self = [super initWithAccessKeyID:AWS_ACCESS_KEY_ID secret:AWS_SECRET_KEY]) {
        self.region = AFAmazonS3USWest2Region;
        self.bucket = BUCKET_NAME;
        [self registerHTTPOperationClass:[AFKissXMLRequestOperation class]];
    }
    return self;
}

@end
