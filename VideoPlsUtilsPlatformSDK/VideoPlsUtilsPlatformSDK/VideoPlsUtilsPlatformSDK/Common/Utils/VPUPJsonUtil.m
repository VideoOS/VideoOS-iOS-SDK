//
//  VPUPJsonUtil.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/17.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPJsonUtil.h"

NSString* VPUP_DictionaryToJson(NSDictionary *dictionary) {
    if(!dictionary) {
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    if(error) {
        return nil;
    }
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //苹果转成的json会带有转义/,替换
    json = [json stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    
    return json;
}

NSString* VPUP_StringArrayToJson(NSArray<NSString *> *array) {
    if(!array || [array count] == 0) {
        return nil;
    }
    
    NSMutableString *jsonString = [NSMutableString stringWithString:@"["];
    for(NSString *concatString in array) {
        [jsonString appendString:concatString];
        [jsonString appendString:@","];
    }
    
    [jsonString deleteCharactersInRange:NSMakeRange([jsonString length] - 1, 1)];
    
    [jsonString appendString:@"]"];
    
    return jsonString;
}

NSDictionary* VPUP_JsonToDictionary(NSString *json) {
    if(!json) {
        return nil;
    }
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    return VPUP_DataToDictionary(jsonData);
}

NSDictionary* VPUP_DataToDictionary(NSData *data) {
    if(!data) {
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    
    if(error) {
        return nil;
    }
    
    return dictionary;
}

@implementation VPUPJsonUtil

@end
