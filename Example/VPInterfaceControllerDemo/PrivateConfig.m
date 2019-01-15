//
//  PrivateConfig.m
//  VPInterfaceControllerDemo
//
//  Created by 李少帅 on 2017/8/3.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "PrivateConfig.h"

NSString *const VPIPrivateConfigPlatformID = @"VPL.PrivateConfig.platformID";
NSString *const VPIPrivateConfigIdentifier = @"VPL.PrivateConfig.identifier";
NSString *const VPIPrivateConfigUserID = @"VPL.PrivateConfig.userID";
NSString *const VPIPrivateConfigCate = @"VPL.PrivateConfig.cate";

@implementation PrivateConfig

+(instancetype)shareConfig {
    
    static PrivateConfig *config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[PrivateConfig alloc] init];
        config.environment = 2;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:VPIPrivateConfigPlatformID]) {
            config.platformID = [[NSUserDefaults standardUserDefaults] objectForKey:VPIPrivateConfigPlatformID];
            config.identifier = [[NSUserDefaults standardUserDefaults] objectForKey:VPIPrivateConfigIdentifier];
            config.userID = [[NSUserDefaults standardUserDefaults] objectForKey:VPIPrivateConfigUserID];
            config.cate = [[NSUserDefaults standardUserDefaults] objectForKey:VPIPrivateConfigCate];
        }
        [config addKeyPathObserver];
    });
    return config;
}

- (void)addKeyPathObserver {
    @try {
        [self addObserver:self forKeyPath:@"platformID" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"identifier" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"userID" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"cate" options:NSKeyValueObservingOptionNew context:nil];
    } @catch (NSException *exception) {
        
    }
}

- (void)removeKeyPathObserver {
    @try {
        [self removeObserver:self forKeyPath:@"platformID" context:nil];
        [self removeObserver:self forKeyPath:@"identifier" context:nil];
        [self removeObserver:self forKeyPath:@"userID" context:nil];
        [self removeObserver:self forKeyPath:@"cate" context:nil];
    } @catch (NSException *exception) {
        
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if([keyPath isEqualToString:@"platformID"]) {
        [[NSUserDefaults standardUserDefaults] setValue:self.platformID forKey:VPIPrivateConfigPlatformID];
    }
    else if([keyPath isEqualToString:@"identifier"]) {
        [[NSUserDefaults standardUserDefaults] setValue:self.identifier forKey:VPIPrivateConfigIdentifier];
    }
    else if([keyPath isEqualToString:@"userID"]) {
        [[NSUserDefaults standardUserDefaults] setValue:self.userID forKey:VPIPrivateConfigUserID];
    }
    else if([keyPath isEqualToString:@"cate"]) {
        [[NSUserDefaults standardUserDefaults] setValue:self.cate forKey:VPIPrivateConfigCate];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
