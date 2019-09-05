//
//  VPUPAVAssetResourceLoader.h
//  ResourceLoader
//
//  Created by peter on 2018/5/4.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class VPUPAVAssetResourceLoader;
@class VPUPVideoRequestTask;

@protocol VPUPAVAssetResourceLoaderDelegate <NSObject>

- (void)didCompleteWithLoader:(VPUPAVAssetResourceLoader *)loader;
- (void)didFailedWithLoader:(VPUPAVAssetResourceLoader *)loader error:(NSError *)error;

@end

@interface VPUPAVAssetResourceLoader : NSObject <AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) VPUPVideoRequestTask *task;
@property (nonatomic, weak) id<VPUPAVAssetResourceLoaderDelegate> delegate;
@property (atomic, assign) BOOL seekRequired; //Seek标识

@end
