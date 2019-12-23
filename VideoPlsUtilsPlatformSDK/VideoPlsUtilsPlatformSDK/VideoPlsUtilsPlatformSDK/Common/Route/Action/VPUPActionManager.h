//
//  VPUPActionManager.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by 鄢江波 on 2017/8/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

//userInfo组装为 key:name  value:luaFileName
extern NSString *const VPUPLLoadErrorNotification;

//lua关闭 userInfo组装为 key:name value: luaName
extern NSString *const VPUPLEndNotification;

extern NSString *const VPUPActionTurnNotification;
extern NSString *const VPUPActionTurnOffNotification;

extern NSString *const VPUPGoodsListRequestNotification;
//userInfo组装为 key:url value:needOpenUrl
extern NSString *const VPUPGoodsListOpenPortraitWebViewNotification;

extern NSString *const VPUPGoodsListNativeEndNotification;

extern NSString *const VPUPDeviceNeedChangeToPortraitNotification;


@interface VPUPActionManager : NSObject

/**
 *  推送跳转
 *  @param action scheme://base64(path) 格式的跳转字符串,path必须base64化
 *  @param data 本次跳转需要携带参数
 *  @param sender 对应接受Notification中的object参数
 */
+ (void)pushAction:(NSString *)action data:(id)data sender:(id)sender;

@end


#pragma mark -- 生成action推荐使用
/**
 *给actionPath添加scheme
 *@param actionPath 需要跳转action
 *@return base64(scheme://actionPath)
 */
FOUNDATION_EXPORT NSString *VPUP_SchemeAddPath(NSString *actionPath, NSString *scheme);

/**
 *给actionPath添加scheme turn
 *@param actionPath 需要跳转action
 *@return base64(turn://actionPath)
 */
FOUNDATION_EXPORT NSString *VPUP_TurnPath(NSString *actionPath);
