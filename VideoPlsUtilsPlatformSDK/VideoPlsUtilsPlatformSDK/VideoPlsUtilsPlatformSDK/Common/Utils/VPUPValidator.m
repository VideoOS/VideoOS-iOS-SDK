//
//  VPUPValidator.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPValidator.h"
#import <UIKit/UIKit.h>

@implementation VPUPValidator


@end

BOOL VPUP_IsExist(id obj) {
    if(obj && obj != [NSNull null]) {
        return YES;
    }
    else {
        return NO;
    }
}

BOOL VPUP_IsStrictExist(id obj) {
    if(VPUP_IsExist(obj)) {
        if([obj isKindOfClass:[NSArray class]]) {
            if([obj count] == 0) {
                return NO;
            }
        }
        if([obj isKindOfClass:[NSDictionary class]]) {
            if([[obj allKeys] count] == 0) {
                return NO;
            }
        }
        if([obj isKindOfClass:[NSString class]]) {
            if([obj isEqualToString:@""]) {
                return NO;
            }
        }
        return YES;
    }
    else {
        return NO;
    }

}

BOOL VPUP_IsStringTrimExist(NSString *obj) {
    if(VPUP_IsExist(obj)) {
        if(VPUP_IsExist(VPUP_StringFromObject(obj))) {
            return YES;
        }
    }
    return NO;
}

NSString* VPUP_StringFromObject(id obj) {
    return VPUP_StringFromObjectNeedTrim(obj, YES);
}

NSString* VPUP_StringFromObjectNeedTrim(id obj, BOOL trim) {
    if([obj isKindOfClass:[NSString class]] ||
       [obj isKindOfClass:[NSNumber class]]) {
        NSString *string = [NSString stringWithFormat:@"%@",obj];
        
        if(trim) {
            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
        if([string isEqualToString:@""]) {
            return nil;
        }
        
        return string;
    }
    return nil;
}

BOOL VPUP_StringContainsString(NSString *string, NSString *insideString) {
    if (@available(iOS 8.0, *)) {
        return [string containsString:insideString];
    } else {
        return [string rangeOfString:insideString].location != NSNotFound;
    }
}

NSUInteger VPUP_IsDealArrayBoundWithIndex(NSArray *array, NSInteger index) {
    return index < 0 ? 0 : (index > [array count] - 1 ? [array count] - 1 : index);
}

id VPUP_GetValue(id value, id defaultValue) {
    if (VPUP_IsExist(value)) {
        return value;
    }
    return defaultValue;
}
