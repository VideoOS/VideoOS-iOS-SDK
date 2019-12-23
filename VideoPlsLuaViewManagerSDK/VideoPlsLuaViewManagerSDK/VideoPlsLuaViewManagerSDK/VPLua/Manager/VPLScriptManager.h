//
//  VPLScriptManager.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2018/1/9.
//  Copyright © 2018年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VPLScriptManagerErrorType) {
    VPLScriptManagerErrorTypeGetVersion,
    VPLScriptManagerErrorTypeDownloadFile,
    VPLScriptManagerErrorTypFileMD5,
    VPLScriptManagerErrorTypeUnzip,
    VPLScriptManagerErrorTypeWriteVersionFile
};
@protocol VPLScriptManagerDelegate;
@protocol VPUPHTTPAPIManager;

@interface VPLScriptManager : NSObject

@property (nonatomic, weak) id<VPLScriptManagerDelegate> delegate;

- (instancetype)initWithLuaStorePath:(NSString *)path
                          apiManager:(id<VPUPHTTPAPIManager>)apiManager
                          versionUrl:(NSString *)url
                       nativeVersion:(NSString *)nativeVersion;

@end

@protocol VPLScriptManagerDelegate <NSObject>

- (void)scriptManager:(VPLScriptManager *)manager error:(NSError *)error errorType:(VPLScriptManagerErrorType)type;

- (void)scriptManager:(VPLScriptManager *)manager downloadSuccessed:(BOOL)success;

@end
