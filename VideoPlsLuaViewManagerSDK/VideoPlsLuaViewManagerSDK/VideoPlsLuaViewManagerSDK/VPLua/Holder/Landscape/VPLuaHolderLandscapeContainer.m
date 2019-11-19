//
//  VPLuaHolderLandscapeContainer.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaHolderLandscapeContainer.h"
#import "VPLuaNodeController.h"
#import "VPUPRoutes.h"
#import "VPUPHexColors.h"
#import "VPUPEncryption.h"
#import "VPLuaLoader.h"
#import "VPUPHexColors.h"
#import "VPUPViewScaleUtil.h"
#import "VPUPPathUtil.h"
#import "VPLuaOSView.h"

@interface VPLuaHolderLandscapeContainer() <VPLuaNodeControllerLoadDelegate, VPLuaNodeControllerHolderDelegate>


@property (nonatomic) VPLuaNodeController *luaController;
//node的栈,从第二个开始算,root不存放在栈中
@property (nonatomic) NSMutableArray *nodeStack;

//holder
@property (nonatomic, assign) BOOL isHolderRetry;
@property (nonatomic) NSString *tempRetryNodeId;
@property (nonatomic) id tempRetryData;
@property (nonatomic, assign) BOOL isHolderError;

@end


@implementation VPLuaHolderLandscapeContainer
@synthesize containerDelegate;

- (void)initContainView {
    
    self.luaController = [[VPLuaNodeController alloc] initWithViewFrame:self.containFrame videoRect:CGRectZero networkManager:self.networkManager videoInfo:self.videoInfo];
    [self.luaController changeDestinationPath:self.holderPath];
    self.luaController.luaDelegate = self;
    self.luaController.holderDelegate = self;
    [self.mainView addSubview:self.luaController.rootView];

}

- (void)updateContainUserInfo {
    if (self.getUserInfoBlock) {
        [self.luaController setGetUserInfoBlock:self.getUserInfoBlock];
    }
}

- (void)loadContainView {
    [self loadLuaFiles];
}

- (void)loadLuaFiles {
    __weak typeof(self) weakSelf = self;
    
    [[VPLuaLoader sharedLoader] checkAndDownloadFilesList:self.holder.luaList resumePath:self.holderPath complete:^(NSError * error, VPUPTrafficStatisticsList *trafficList) {
       //已回到主线程
        if (trafficList) {
            [VPUPTrafficStatistics sendTrafficeStatistics:trafficList type:VPUPTrafficTypeRealTime];
        }
        
        if (error) {
            weakSelf.retryLuaFiles = YES;
            [weakSelf showRetryView];
            [weakSelf.retryView changeNetworkMessage:@"小程序加载失败，请重试"];
            return;
        }
        
        [weakSelf updateNavi];
        [weakSelf loadRootLua];
    }];
}

- (void)loadRootLua {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self closeLoadingView];
        [self.luaController loadLua:self.holder.templateLua data:self.rootData];
    });
}

- (void)loadLua:(NSString *)luaUrl data:(NSDictionary *)data {
    if (!_nodeStack) {
        _nodeStack = [NSMutableArray array];
    }
    NSDictionary *queryParams = [data objectForKey:VPUPRouteQueryParamsKey];
    NSString *nodeId = [queryParams objectForKey:@"id"];
    if (![_nodeStack containsObject:nodeId]) {
        [_nodeStack addObject:nodeId];
    }
    
    if(_nodeStack.count > 0) {
        [self.naviBar showBackButton];
    }
    
    [self.luaController loadLua:luaUrl data:data];
}

- (void)refreshContainerWithData:(id)data {
    [self closeLoadingView];
    [self closeRetryView];
    [self closeErrorView];
    self.rootData = data;
    NSDictionary *newData = [self getInitData];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @(VPLuaHolderActionTypeRefresh),@"holderActionType",
                          @(VPLuaEventTypeHolderAction), @"eventType",
                          newData, @"data", nil];
    
    NSString *nodeID = nil;
    if ([self.nodeStack count] > 0) {
        nodeID = [self.nodeStack lastObject];
    }
    
    if (nodeID != nil) {
        [self.luaController callLuaMethod:@"event" nodeId:nodeID data:dict];
    } else {
        [self.luaController callLuaMethod:@"event" data:dict];
    }
}

- (void)naviBackButtonTapped {
    if ([_nodeStack count] > 0) {
        [_nodeStack removeLastObject];
        if ([_nodeStack count] == 0) {
            [self.naviBar hideBackButton];
        }
        if (self.errorView && self.errorView.hidden == NO) {
            [self closeErrorView];
            //小程序唤起的错误页,需要移除node;lua加载引发的错误页,不需要移除node
            if (_isHolderError) {
                _isHolderError = NO;
                [_luaController removeLastNode];
            }
        } else {
            if (self.retryView && self.retryView.hidden == NO) {
                //当前页面没有重试就回退了,置空所有参数
                if (_isHolderError) {
                    _isHolderError = NO;
                    _tempRetryNodeId = nil;
                    _tempRetryData = nil;
                }
                [self closeRetryView];
            }
            [_luaController removeLastNode];
        }
    } else {
        [self.naviBar hideBackButton];
    }
}

- (void)destroyView {
    [self.luaController releaseLuaView];
    [super destroyView];
}

#pragma mark - delegate
//network
- (void)retryNetwork {
    [self showLoadingView];
    if (!_isHolderRetry) {
        [self showLoadingView];
        if (self.retryLuaFiles) {
            self.retryLuaFiles = false;
            [self loadLuaFiles];
        } else {
            [super retryNetwork];
        }
    } else {
        _isHolderRetry = NO;
        [self closeRetryView];
        if (_tempRetryNodeId) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @(VPLuaHolderActionTypeRetry),@"holderActionType",
                                  @(VPLuaEventTypeHolderAction), @"eventType",
                                  _tempRetryData, @"data", nil];
            [self.luaController callLuaMethod:@"event" nodeId:_tempRetryNodeId data:dict];
        }
        _tempRetryNodeId = nil;
        _tempRetryData = nil;
    }
    
}

//lua node controller
- (void)loadLuaError:(NSString *)error {
    [self showErrorView];
    if (_nodeStack.count == 0) {
        [self.errorView useDefaultMessage];
    } else {
        [self.errorView changeErrorMessage:@"小程序崩溃了"];
    }
}

- (void)showRetryPage:(NSString *)retryMessage retryData:(id)data nodeId:(NSString *)nodeId {
    [self showRetryView];
    if (retryMessage != nil && ![retryMessage isEqualToString:@""]) {
        [self.retryView changeNetworkMessage:retryMessage];
    } else {
        [self.retryView useDefaultMessage];
    }
    _isHolderRetry = YES;
    _tempRetryData = data;
    _tempRetryNodeId = nodeId;
}

- (void)showErrorPage:(NSString *)errorMessage {
    _isHolderError = YES;
    [self showErrorView];
    if (errorMessage != nil && ![errorMessage isEqualToString:@""]) {
        [self.errorView changeErrorMessage:errorMessage];
    } else {
        [self.errorView useDefaultMessage];
    }

}

@end
