//
//  VPUPUrlUtil.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 2019/3/17.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPUPUrlUtil.h"

@implementation VPUPUrlUtil

NSString * VPUPPercentEscapedStringFromString(NSString *string) {
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < string.length) {
        NSUInteger length = MIN(string.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    return escaped;
}

+ (NSString *)urlencode:(NSString *)url {
    if (!url) {
        return nil;
    }
    NSString *urlString = nil;
    if ([url rangeOfString:@"https://"].location == 0) {
        urlString = [NSString stringWithFormat:@"https://%@",VPUPPercentEscapedStringFromString([url substringFromIndex:8])];
    }
    else if ([url rangeOfString:@"http://"].location == 0) {
        urlString = [NSString stringWithFormat:@"http://%@",VPUPPercentEscapedStringFromString([url substringFromIndex:7])];
    }
    
    if (!urlString) {
        urlString = VPUPPercentEscapedStringFromString(url);
    }
    
    return urlString;
}

@end
