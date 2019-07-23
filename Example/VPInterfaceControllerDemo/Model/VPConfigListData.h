//
//  VPConfigListData.h
//  VideoOSDemo
//
//  Created by Zard1096-videojj on 2019/2/26.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPConfigData.h"

NS_ASSUME_NONNULL_BEGIN

@interface VPConfigListData : NSObject

+ (VPConfigListData *)shared;

@property (nonatomic, readonly) NSMutableArray<VPConfigData *> *data;
@property (nonatomic, assign) NSInteger selectedIndex;

- (NSArray *)appKeyArray;
- (NSArray *)appSecretArray;

- (void)addConfigData:(VPConfigData *)configData;

@end

NS_ASSUME_NONNULL_END
