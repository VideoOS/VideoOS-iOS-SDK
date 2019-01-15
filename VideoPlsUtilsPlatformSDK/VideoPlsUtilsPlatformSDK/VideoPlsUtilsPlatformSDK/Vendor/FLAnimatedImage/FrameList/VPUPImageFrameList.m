//
//  VPUPImageFrameList.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/8/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPImageFrameList.h"
#import "VPUPValidator.h"
#import "VPUPImageFrame.h"

@implementation VPUPImageFrameList

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
        if(![self readImageFrameListDictionary:dictionary]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)readImageFrameListDictionary:(NSDictionary *)dictionary {
    
    if(!VPUP_IsStrictExist([dictionary objectForKey:@"frames"]) ||
       !VPUP_IsStrictExist([dictionary objectForKey:@"path"])) {
        return NO;
    }
    
    _path = [dictionary objectForKey:@"path"];
    
    NSArray *frames = [dictionary objectForKey:@"frames"];
    
    _frames = [NSMutableArray array];
    
    for(NSDictionary *frameDict in frames) {
        VPUPImageFrame *frame = [[VPUPImageFrame alloc] initWithDictionary:frameDict urlPath:_path];
        if(!frame) {
            //someting error
            
        }
        
        [_frames addObject:frame];
    }
    
    _loop = 0;
    if(VPUP_IsExist([dictionary objectForKey:@"loop"])) {
        _loop = [[dictionary objectForKey:@"loop"] integerValue];
        if(_loop == -1) {
            _loop = 0;
        }
    }
    
    
    return YES;
}

@end
