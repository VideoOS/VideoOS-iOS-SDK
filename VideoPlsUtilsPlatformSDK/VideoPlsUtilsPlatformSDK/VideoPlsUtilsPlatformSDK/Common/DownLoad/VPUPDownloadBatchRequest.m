//
//  VPUPDownloadBatchRequest.m
//  ResumeDownloader
//
//  Created by peter on 14/11/2017.
//  Copyright © 2017 videopls.com. All rights reserved.
//

#import "VPUPDownloadBatchRequest.h"
#import "VPUPDownloadRequest.h"

@interface VPUPDownloadBatchRequest()

@property (nonatomic, strong, readwrite) NSMutableArray<VPUPDownloadRequest *> *requestArray;

@end

@implementation VPUPDownloadBatchRequest

- (instancetype)init
{
    return [self initWithRequestArray:nil];
}

- (instancetype)initWithRequestArray:(NSArray<VPUPDownloadRequest *> *)requestArray
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    self.requestArray = [NSMutableArray<VPUPDownloadRequest *> arrayWithCapacity:0];
    if (requestArray && requestArray.count>0)
    {
        [self.requestArray addObjectsFromArray:requestArray];
    }
    return self;
}

- (void)addRequest:(VPUPDownloadRequest *)request
{
    if (request)
    {
        [self.requestArray addObject:request];
    }
}

- (void)addBatchRequests:(NSArray<VPUPDownloadRequest *> *)requestArray
{
    if (requestArray && requestArray.count>0)
    {
        [self.requestArray addObjectsFromArray:requestArray];
    }
}

@end
