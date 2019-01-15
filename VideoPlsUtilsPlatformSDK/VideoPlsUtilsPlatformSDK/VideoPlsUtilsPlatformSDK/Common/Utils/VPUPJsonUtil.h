//
//  VPUPJsonUtil.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/17.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * 字典转json
 * @param dictionary 需要专成json的字典
 * @return json字符串
 */
FOUNDATION_EXPORT NSString* VPUP_DictionaryToJson(NSDictionary *dictionary);

/**
 * 字符串数组组成json
 * @param array 字符串数组
 * @return json字符串
 */
FOUNDATION_EXPORT NSString* VPUP_StringArrayToJson(NSArray<NSString *> *array);

/**
 * json转字典
 * @param json json字符串
 * @return 字典
 */
FOUNDATION_EXPORT NSDictionary* VPUP_JsonToDictionary(NSString *json);

/**
 * data转字典
 * @param data json字符串data
 * @return 字典
 */
FOUNDATION_EXPORT NSDictionary* VPUP_DataToDictionary(NSData *data);


@interface VPUPJsonUtil : NSObject

@end
