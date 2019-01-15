//
//  VPUPImageFrame.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/8/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPImageFrame.h"
#import "VPUPValidator.h"

@implementation VPUPImageFrame

- (instancetype)initWithDictionary:(NSDictionary *)dictionary urlPath:(NSString *)urlPath {
    self = [super init];
    if(self) {
        if(![self readImageFrameListDictionary:dictionary urlPath:urlPath]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)readImageFrameListDictionary:(NSDictionary *)dictionary urlPath:(NSString *)urlPath {
    
    if(!VPUP_IsStrictExist([dictionary objectForKey:@"duration"]) ||
       !VPUP_IsStrictExist([dictionary objectForKey:@"name"])) {
        return NO;
    }
    
    _duration = [[dictionary objectForKey:@"duration"] unsignedIntegerValue];
    _name = [dictionary objectForKey:@"name"];
    
    _imageURL = [NSURL URLWithString:_name relativeToURL:[NSURL URLWithString:urlPath]];
    
    _jumpTo = NSUIntegerMax;
    _jumpMax = NSUIntegerMax;
    _jumpCount = 0;
    
    if(VPUP_IsExist([dictionary objectForKey:@"jumpTo"]) &&
       VPUP_IsExist([dictionary objectForKey:@"jumpMax"])) {
        _jumpTo = [[dictionary objectForKey:@"jumpTo"] unsignedIntegerValue];
        _jumpMax = [[dictionary objectForKey:@"jumpMax"] unsignedIntegerValue];
    }
    
    if(_jumpTo == NSUIntegerMax || _jumpMax == 0 || _jumpMax == NSUIntegerMax) {
        _jumpTo = NSUIntegerMax;
        _jumpMax = NSUIntegerMax;
    }
    
    return YES;
}

@end
