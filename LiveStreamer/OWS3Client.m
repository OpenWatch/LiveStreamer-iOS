//
//  OWS3Client.m
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/3/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import "OWS3Client.h"

@implementation OWS3Client
@synthesize s3, networkQueue, callbackQueue, region, useSSL;

- (id) initWithAccessKey:(NSString*)accessKey secretKey:(NSString*)secretKey {
    if (self = [super init]) {
        // Initial the S3 Client.
        // Logging Control - Do NOT use logging for non-development builds.
#ifdef DEBUG
        [AmazonLogger verboseLogging];
#else
        [AmazonLogger turnLoggingOff];
#endif
        [AmazonErrorHandler shouldNotThrowExceptions];
        self.s3 = [[AmazonS3Client alloc] initWithAccessKey:accessKey withSecretKey:secretKey];
        region = US_EAST_1;
        useSSL = YES;
        [self refreshEndpoint];
        self.networkQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.callbackQueue = dispatch_get_main_queue();
    }
    return self;
}

- (void) refreshEndpoint {
    self.s3.endpoint = [AmazonEndpoints s3Endpoint:self.region secure:self.useSSL];
}

- (void) setRegion:(AmazonRegion)_region {
    region = _region;
    [self refreshEndpoint];
}

- (void) setUseSSL:(BOOL)_useSSL {
    useSSL = _useSSL;
    [self refreshEndpoint];
}

- (void)postObjectWithFile:(NSString *)path
                    bucket:(NSString*)bucket
                       key:(NSString *)key
                       acl:(NSString*)acl
                   success:(void (^)(S3PutObjectResponse *responseObject))success
                   failure:(void (^)(NSError *error))failure {
    dispatch_async(networkQueue, ^{
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:key inBucket:bucket];
        por.filename  = path;
        
        S3CannedACL *cannedACL = nil;
        if (acl) {
            cannedACL = [[S3CannedACL alloc] initWithStringValue:acl];
        } else {
            cannedACL = [S3CannedACL publicRead];
        }
        por.cannedACL = cannedACL;
        
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
        
        if (putObjectResponse.error) {
            if (failure) {
                dispatch_async(callbackQueue, ^{
                    failure(putObjectResponse.error);
                });
            }
            return;
        }
        
        if (success) {
            dispatch_async(callbackQueue, ^{
                success(putObjectResponse);
            });
        }
    });
}

@end
