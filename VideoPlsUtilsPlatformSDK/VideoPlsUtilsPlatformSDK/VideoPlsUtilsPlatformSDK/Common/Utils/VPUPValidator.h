//
//  VPUPValidator.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * 检测对象是否为nil或null
 * @param obj 检测对象
 * @return 是否为空(Array和Dictionary内容为空以及字符串为@""也存在)
 */
FOUNDATION_EXPORT BOOL VPUP_IsExist(id obj);

/**
 * 严格检测对象是否为空
 * @param obj 检测对象
 * @return 是否为空(Array和Dictionary内容为空以及字符串为@""作为不存在)
 */
FOUNDATION_EXPORT BOOL VPUP_IsStrictExist(id obj);

/**
 * 字符串去空格后是否为空
 * @param obj 字符串
 * @return 是否为空
 */
FOUNDATION_EXPORT BOOL VPUP_IsStringTrimExist(NSString *obj);

/**
 * 字符串去空格
 * @param obj 字符串或NSNumber
 * @return 去空格后的字符串
 */
FOUNDATION_EXPORT NSString* VPUP_StringFromObject(id obj);

/**
 * 字符串去空格
 * @param obj 字符串或NSNumber
 * @return 去空格后的字符串
 */
FOUNDATION_EXPORT NSString* VPUP_StringFromObjectNeedTrim(id obj, BOOL trim);


FOUNDATION_EXPORT BOOL VPUP_StringContainsString(NSString *string, NSString *insideString);
/**
  * 处理数组越界
  * @param array 检测数组
  * @param index 需要使用的index
  * @return 不会越界的index
  */
FOUNDATION_EXPORT NSUInteger VPUP_IsDealArrayBoundWithIndex(NSArray *array, NSInteger index);

/**
 *
 */
FOUNDATION_EXPORT id VPUP_GetValue(id value, id defaultValue);

@interface VPUPValidator : NSObject

@end
