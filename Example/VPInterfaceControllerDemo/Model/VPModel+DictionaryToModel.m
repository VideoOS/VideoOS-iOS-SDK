//
//  VPModel+DictionaryToModel.m
//  VideoOSDemo
//
//  Created by Zard1096-videojj on 2019/2/26.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPModel+DictionaryToModel.h"
#import <objc/message.h>

@implementation VPModel (DictionaryToModel)

+ (instancetype)modelWithDictionary:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    //1. 创建对应的对象
    id model = [[self alloc] init];
    
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList(self, &count);
    
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        // 获取成员变量名字
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 处理成员变量名->字典中的key(去掉 _ ,从第一个角标开始截取)
        NSString *key = [ivarName substringFromIndex:1];
        
        // 根据成员属性名去字典中查找对应的value
        id value = dict[key];
        
        if (value) {
            [model setValue:value forKey:key];
        }
    }
    
    return model;
}

- (NSDictionary *)modelToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        // 获取成员变量名字
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 处理成员变量名->字典中的key(去掉 _ ,从第一个角标开始截取)
        NSString *key = [ivarName substringFromIndex:1];
        
        // 根据成员属性名去字典中查找对应的value
        id value = [self valueForKey:key];
        
        if (value) {
            [dict setValue:value forKey:key];
        }
    }
    
    return dict;
}

@end
