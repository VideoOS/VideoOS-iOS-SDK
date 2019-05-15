//
//  VPLuaScriptManager.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2018/1/9.
//  Copyright © 2018年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VPLuaScriptManagerErrorType) {
    VPLuaScriptManagerErrorTypeGetVersion,
    VPLuaScriptManagerErrorTypeDownloadFile,
    VPLuaScriptManagerErrorTypFileMD5,
    VPLuaScriptManagerErrorTypeUnzip,
    VPLuaScriptManagerErrorTypeWriteVersionFile
};
@protocol VPLuaScriptManagerDelegate;
@protocol VPUPHTTPAPIManager;

@interface VPLuaScriptManager : NSObject

@property (nonatomic, weak) id<VPLuaScriptManagerDelegate> delegate;

- (instancetype)initWithLuaStorePath:(NSString *)path
                          apiManager:(id<VPUPHTTPAPIManager>)apiManager
                          versionUrl:(NSString *)url
                       nativeVersion:(NSString *)nativeVersion;

@end

@protocol VPLuaScriptManagerDelegate <NSObject>

- (void)scriptManager:(VPLuaScriptManager *)manager error:(NSError *)error errorType:(VPLuaScriptManagerErrorType)type;

- (void)scriptManager:(VPLuaScriptManager *)manager downloadSuccessed:(BOOL)success;

@end
