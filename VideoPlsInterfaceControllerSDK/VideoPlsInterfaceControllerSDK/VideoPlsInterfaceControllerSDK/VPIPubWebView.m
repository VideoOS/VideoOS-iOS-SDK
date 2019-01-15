//
//  VPIPubWebView.m
//  VideoPlsInterfaceControllerSDK
//
//  Created by 鄢江波 on 2017/9/25.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPIPubWebView.h"
#import "VPIUserLoginInterface.h"
#import <VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h>

@interface VPIPubWebView()

@property (nonatomic, strong) NSDictionary *(^bGetUserInfoBlock)(void);

@end

@implementation VPIPubWebView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWebViewParams];
    }
    return self;
}

- (void)initWebViewParams {
    __weak typeof(self)  weakSelf = self;
    _bGetUserInfoBlock = ^NSDictionary *(void) {
        return [weakSelf getUserInfoDictionary];
    };
    [self setGetUserInfoBlock:_bGetUserInfoBlock];
}

- (NSDictionary *)getUserInfoDictionary {
    VPIUserInfo * userInfo = [self.userDelegate vp_getUserInfo];
    if (!userInfo) {
        return nil;
    }
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    if(!userInfo.uid) {
        return nil;
    }
    
    [dictionary setObject:userInfo.uid forKey:@"uid"];
    
    if(userInfo.token) {
        [dictionary setObject:userInfo.token forKey:@"token"];
    }
    if(userInfo.nickName) {
        [dictionary setObject:userInfo.nickName forKey:@"nickName"];
    }
    if(userInfo.userName) {
        [dictionary setObject:userInfo.userName forKey:@"userName"];
    }
    if(userInfo.phoneNum) {
        [dictionary setObject:userInfo.phoneNum forKey:@"phoneNum"];
    }
    
    return dictionary;
}

- (void)userLogin:(NSDictionary *)userInfoData {
    if (self.userDelegate) {
        NSDictionary *dic = userInfoData;
        if (dic) {
            VPIUserInfo *userInfo = [[VPIUserInfo alloc] init];
            if(![dic objectForKey:@"uid"]) {
                return;
            }
            userInfo.uid = [dic objectForKey:@"uid"];
            if([dic objectForKey:@"nickName"]) {
                userInfo.nickName = [dic objectForKey:@"nickName"];
            }
            if([dic objectForKey:@"token"]) {
                userInfo.token = [dic objectForKey:@"token"];
            }
            if([dic objectForKey:@"phoneNum"]) {
                userInfo.phoneNum = [dic objectForKey:@"phoneNum"];
            }
            if ([dic objectForKey: @"userName"]) {
                userInfo.userName = [dic objectForKey:@"userName"];
            }
            [self.userDelegate vp_userLogined:userInfo];
        }
    }
}

- (void)loadUrl:(NSString *)url {
    [self loadUrlString:url];
}

- (void)closeAndRemoveFromSuperView {
    [self stopAndRemoveWebView];
    _bGetUserInfoBlock = nil;
}

- (void)webViewNeedClose {
    if([self.delegate respondsToSelector:@selector(webViewNeedClose)]) {
        [self.delegate webViewNeedClose];
    }
}

-(void)dealloc {
    [self stopAndRemoveWebView];
    _bGetUserInfoBlock = nil;
}

@end
