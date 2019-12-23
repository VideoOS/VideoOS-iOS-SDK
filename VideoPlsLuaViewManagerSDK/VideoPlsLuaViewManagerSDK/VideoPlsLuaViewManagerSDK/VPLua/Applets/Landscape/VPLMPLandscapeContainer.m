//
//  VPLMPLandscapeContainer.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLMPLandscapeContainer.h"
#import "VPLNodeController.h"
#import "VPUPRoutes.h"
#import "VPUPHexColors.h"
#import "VPUPEncryption.h"
#import "VPLDownloader.h"
#import "VPUPHexColors.h"
#import "VPUPViewScaleUtil.h"
#import "VPUPPathUtil.h"
#import "VPLOSView.h"
#import "VPLSDK.h"

@interface VPLMPLandscapeContainer() <VPLNodeControllerLoadDelegate, VPLNodeControllerMPDelegate>


@property (nonatomic) VPLNodeController *nodeController;
//node的栈,从第二个开始算,root不存放在栈中
@property (nonatomic) NSMutableArray *nodeStack;

//applet
@property (nonatomic, assign) BOOL isMPRetry;
@property (nonatomic) NSString *tempRetryNodeId;
@property (nonatomic) id tempRetryData;
@property (nonatomic, assign) BOOL isMPError;

@end


@implementation VPLMPLandscapeContainer
@synthesize containerDelegate;

- (void)initContainView {
    
    self.nodeController = [[VPLNodeController alloc] initWithViewFrame:self.containFrame videoRect:CGRectZero networkManager:self.networkManager videoInfo:self.videoInfo];
    [self.nodeController changeDestinationPath:self.mpPath];
    self.nodeController.nodeDelegate = self;
    self.nodeController.mpDelegate = self;
    [self.mainView addSubview:self.nodeController.rootView];

}

- (void)updateContainView {
    [self.nodeController updateFrame:self.containFrame isPortrait:NO isFullScreen:YES];
}

- (void)updateContainUserInfo {
    if (self.getUserInfoBlock) {
        [self.nodeController setGetUserInfoBlock:self.getUserInfoBlock];
    }
}

- (void)loadContainView {
    [self loadLFileFiles];
}

- (void)loadLFileFiles {
    __weak typeof(self) weakSelf = self;
    if (![VPLSDK sharedSDK].appDev) {
        //normal use
        [[VPLDownloader sharedDownloader] checkAndDownloadFilesList:self.mpObject.miniAppInfo.luaList resumePath:self.mpPath complete:^(NSError * error, VPUPTrafficStatisticsList *trafficList) {
            //已回到主线程
            if (trafficList) {
                [VPUPTrafficStatistics sendTrafficeStatistics:trafficList type:VPUPTrafficTypeRealTime];
            }
            
            if (error) {
                weakSelf.retryLFiles = YES;
                [weakSelf showRetryView];
                [weakSelf.retryView changeNetworkMessage:@"小程序加载失败，请重试"];
                return;
            }
            
            [weakSelf updateNavi];
            [weakSelf loadRootLua];
        }];
    } else {
        //mini app develop mode
        [self updateNavi];
        [self loadRootLua];
    }
}

- (void)loadRootLua {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self closeLoadingView];
        [self.nodeController loadLFile:self.mpObject.miniAppInfo.template data:self.rootData];
    });
}

- (void)loadLFile:(NSString *)luaUrl data:(NSDictionary *)data {
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
    
    [self.nodeController loadLFile:luaUrl data:data];
}

- (void)refreshContainerWithData:(id)data {
    [self closeLoadingView];
    [self closeRetryView];
    [self closeErrorView];
    self.rootData = data;
    NSDictionary *newData = [self getInitData];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @(VPLMPActionTypeRefresh),@"appletActionType",
                          @(VPLEventTypeMPAction), @"eventType",
                          newData, @"data", nil];
    
    NSString *nodeID = nil;
    if ([self.nodeStack count] > 0) {
        nodeID = [self.nodeStack lastObject];
    }
    
    if (nodeID != nil) {
        [self.nodeController callLMethod:@"event" nodeId:nodeID data:dict];
    } else {
        [self.nodeController callLMethod:@"event" data:dict];
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
            if (_isMPError) {
                _isMPError = NO;
                [_nodeController removeLastNode];
            }
        } else {
            if (self.retryView && self.retryView.hidden == NO) {
                //当前页面没有重试就回退了,置空所有参数
                if (_isMPError) {
                    _isMPError = NO;
                    _tempRetryNodeId = nil;
                    _tempRetryData = nil;
                }
                [self closeRetryView];
            }
            [_nodeController removeLastNode];
        }
    } else {
        [self.naviBar hideBackButton];
    }
}

- (void)destroyView {
    [self.nodeController releaseLuaView];
    [super destroyView];
}

#pragma mark - delegate
//network
- (void)retryNetwork {
    [self showLoadingView];
    if (!_isMPRetry) {
        [self showLoadingView];
        if (self.retryLFiles) {
            self.retryLFiles = false;
            [self loadLFileFiles];
        } else {
            [super retryNetwork];
        }
    } else {
        _isMPRetry = NO;
        [self closeRetryView];
        if (_tempRetryNodeId) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @(VPLMPActionTypeRetry),@"appletActionType",
                                  @(VPLEventTypeMPAction), @"eventType",
                                  _tempRetryData, @"data", nil];
            [self.nodeController callLMethod:@"event" nodeId:_tempRetryNodeId data:dict];
        }
        _tempRetryNodeId = nil;
        _tempRetryData = nil;
    }
    
}

//lua node controller
- (void)loadLFileError:(NSString *)error {
    [self showErrorView];
    if (_nodeStack.count == 0) {
        [self.errorView useDefaultMessage];
    } else {
        [self.errorView changeErrorMessage:@"小程序崩溃了"];
    }
}

// applet bridge delegate
- (void)showRetryPage:(NSString *)retryMessage retryData:(id)data nodeId:(NSString *)nodeId {
    [self showRetryView];
    if (retryMessage != nil && ![retryMessage isEqualToString:@""]) {
        [self.retryView changeNetworkMessage:retryMessage];
    } else {
        [self.retryView useDefaultMessage];
    }
    _isMPRetry = YES;
    _tempRetryData = data;
    _tempRetryNodeId = nodeId;
}

- (void)showErrorPage:(NSString *)errorMessage {
    _isMPError = YES;
    [self showErrorView];
    if (errorMessage != nil && ![errorMessage isEqualToString:@""]) {
        [self.errorView changeErrorMessage:errorMessage];
    } else {
        [self.errorView useDefaultMessage];
    }

}

- (BOOL)canGoBack {
    if ([_nodeStack count] == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (void)goBack {
    [self naviBackButtonTapped];
}

- (void)closeView {
    SEL selector = NSSelectorFromString(@"naviCloseButtonTapped");
    if ([self respondsToSelector:selector]) {
        [self performSelector:selector withObject:nil];
    }
}

@end
