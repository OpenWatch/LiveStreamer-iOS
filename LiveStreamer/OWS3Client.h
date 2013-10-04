//
//  OWS3Client.h
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/3/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmazonEndpoints.h"
#import "S3/AmazonS3Client.h"

@interface OWS3Client : NSObject

@property (nonatomic, strong) AmazonS3Client *s3;
@property (nonatomic) dispatch_queue_t networkQueue; // defaults to DISPATCH_QUEUE_PRIORITY_DEFAULT
@property (nonatomic) dispatch_queue_t callbackQueue; //defaults to dispatch_get_main_queue
@property (nonatomic) AmazonRegion region; //defaults to US East 1
@property (nonatomic) BOOL useSSL; //defaults to YES

- (id) initWithAccessKey:(NSString*)accessKey secretKey:(NSString*)secretKey;

/**
 Adds an object to a bucket using forms.
 
 @param path The path to the local file.
 @param bucket The destination bucket.
 @param key Optional. Defaults to the last path component of `path`.
 @param acl Optional. If unset it uses the global value for acl which defaults to public-read. You probably want either public-read or private. For more info check out S3CannedACL.h in aws-sdk-ios.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes a single argument: the response object from the server.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a single argument: the `NSError` object describing error that occurred.
 */
- (void)postObjectWithFile:(NSString *)path
                    bucket:(NSString*)bucket
                       key:(NSString *)key
                       acl:(NSString*)acl
                   success:(void (^)(S3PutObjectResponse *responseObject))success
                   failure:(void (^)(NSError *error))failure;
@end
