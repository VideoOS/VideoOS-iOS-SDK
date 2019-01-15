//
//  VPIPubWebView.h
//  VideoPlsInterfaceControllerSDK
//
//  Created by 鄢江波 on 2017/9/25.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPMGoodsListStorePublicWebView.h"
@protocol VPIUserLoginInterface;

@protocol VPIPubWebViewCloseDelegate <NSObject>

@optional

/**
 * 用户在页面内操作关闭网页, 需要调用 closeAndRemoveFromSuperView 来解除绑定和从superview上移除
 */
- (void)webViewNeedClose;

@end

@interface VPIPubWebView : VPMGoodsListStorePublicWebView

@property (nonatomic, weak) id<VPIPubWebViewCloseDelegate> delegate;
@property (nonatomic, weak) id<VPIUserLoginInterface> userDelegate;

- (void)loadUrl:(NSString *)url;

- (void)closeAndRemoveFromSuperView;

@end
