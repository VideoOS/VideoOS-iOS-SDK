//
//  VPUPImageFrame.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/8/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPImageFrame : NSObject

@property (nonatomic, assign) NSUInteger jumpTo;        //needn't jump NSUIntegerMax
@property (nonatomic, assign) NSUInteger jumpMax;       //needn't jump NSUIntegerMax
@property (nonatomic) NSString *name;
@property (nonatomic, assign) NSUInteger duration;

@property (nonatomic, assign) NSUInteger jumpCount;

@property (nonatomic) NSURL *imageURL;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary urlPath:(NSString *)urlPath;

- (BOOL)readImageFrameListDictionary:(NSDictionary *)dictionary urlPath:(NSString *)urlPath;

@end
