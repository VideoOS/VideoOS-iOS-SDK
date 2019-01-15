//
//  VPUPImageFrameList.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/8/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VPUPImageFrame;

@interface VPUPImageFrameList : NSObject

@property (nonatomic) NSMutableArray<VPUPImageFrame *> *frames;
@property (nonatomic) NSString *path;
@property (nonatomic, assign) NSInteger loop;          //(from network:-1,0 infinite loop, in FrameList 0 => infinite)


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (BOOL)readImageFrameListDictionary:(NSDictionary *)dictionary;

@end
