//
//  VPModel+DictionaryToModel.h
//  VideoOSDemo
//
//  Created by Zard1096-videojj on 2019/2/26.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VPModel (DictionaryToModel)

+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)modelToDictionary;

@end

NS_ASSUME_NONNULL_END
