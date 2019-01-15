//
//  VPLuaRefreshCollectionView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096 on 2017/12/8.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLuaRefreshCollectionView.h"
#import "VPLuaNormalRefreshHeader.h"
#import "LuaViewCore.h"
#import "LVHeads.h"
#import "UIScrollView+LVRefresh.h"

@interface VPLuaRefreshCollectionView()

//@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation VPLuaRefreshCollectionView

#pragma mark -- LVRefreshHeader api

- (void)lv_initRefreshHeader {// 初始化下拉刷新功能
    VPLuaNormalRefreshHeader* refreshHeader = [[VPLuaNormalRefreshHeader alloc] init];
        
    self.lv_refresh_header = refreshHeader;
    __weak typeof(self) weakSelf = self;
    refreshHeader.refreshingBlock = ^(){
        [weakSelf lv_refreshHeaderToRefresh];
    };
}

- (void)lv_hiddenRefreshHeader:(BOOL)hidden {
    self.lv_refresh_header.hidden = hidden;
}

- (void)lv_beginRefreshing {// 进入刷新状态
    //FIX: ??手动调用能触发但下拉刷新并不能触发,但如果在pull down中触发startRefresh又会触发两次刷新
    [self.lv_refresh_header beginRefreshing];
}

- (void)lv_endRefreshing {// 结束刷新状态
    [self.lv_refresh_header endRefreshing];
}

- (void) lv_initRefreshFooter{// 初始化上拉加载更多功能
    
}

- (void) lv_noticeNoMoreData{// 提示没有更多的数据
}

- (void) lv_resetNoMoreData{// 重置没有更多的数据（消除没有更多数据的状态）
}



+ (NSString *)globalName {
    return @"VPRefreshCollectionView";
}


@end
