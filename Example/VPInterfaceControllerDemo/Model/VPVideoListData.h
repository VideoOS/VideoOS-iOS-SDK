//
//  VPVideoListData.h
//  VPInterfaceControllerDemo
//
//  Created by Zard1096-videojj on 2019/8/6.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPVideoData.h"

NS_ASSUME_NONNULL_BEGIN

@interface VPVideoListData : NSObject

+ (VPVideoListData *)shared;

@property (nonatomic, readonly) NSMutableArray<VPVideoData *> *data;
@property (nonatomic, assign) NSInteger selectedIndex;

- (NSArray *)videoUrlArray;
- (NSArray *)videoIdArray;

- (void)addVideoData:(VPVideoData *)videoData;

@end

NS_ASSUME_NONNULL_END
