//
//  OWS3Client.h
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/3/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFAmazonS3Client.h"

@interface OWS3Client : AFAmazonS3Client

+ (OWS3Client*) sharedClient;

@end
