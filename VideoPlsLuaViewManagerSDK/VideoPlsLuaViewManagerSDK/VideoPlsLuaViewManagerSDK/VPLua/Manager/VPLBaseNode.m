//
//  VPLBaseNode.m
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/8/29.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLBaseNode.h"
#import "VPLNodeController.h"
#import "VPLBaseView.h"
#import "VPLClickThroughView.h"
#import "VPLNativeBridge.h"

@interface VPLBaseNode()

@property (nonatomic) VPLBaseView *rootView;
@property (nonatomic, copy) NSString *baseViewClass;

@end

@implementation VPLBaseNode

- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame baseView:NSStringFromClass([VPLBaseView class])];
}

- (instancetype)initWithFrame:(CGRect)frame baseView:(NSString*)baseViewClass
{
    self = [super init];
    if (self) {
        VPLBaseView *view = [[NSClassFromString(baseViewClass) alloc] initWithFrame:frame];
        _rootView = view;
        _lvCore = _rootView.lv_luaviewCore;
        _lvCore.viewController = (id)self;
        _baseViewClass = baseViewClass;
    }
    return self;
}

- (NSString *)runLuaFile:(NSString *)filePath data:(id)data {
    
    NSString *runFileReslut = [_rootView runFile:filePath];
    
    if(runFileReslut) {
        return runFileReslut;
    }
    
    NSString *callFunResult = [self callMethod:@"show" data:data];
    
    return callFunResult;
    
}

- (NSString *)callMethod:(NSString *)method data:(id)data  {
    NSArray *args;
    if(data) {
        args = @[data];
    }
    
    NSString *callFunResult = [_rootView callLua:method args:args];
    
    if(callFunResult) {
        return callFunResult;
    }

    return nil;
}

- (UIView *)builRootView {
    if(_rootView) {
        return _rootView;
    }
    if (!_baseViewClass) {
        _baseViewClass = NSStringFromClass([VPLBaseView class]);
    }
    
    VPLBaseView *view = [[NSClassFromString(_baseViewClass) alloc] init];
    _rootView = view;
    
    return view;
}

- (void)updateFrame:(CGRect)frame isPortrait:(BOOL)isPortraitScreen isFullScreen:(BOOL)isFullScreen {
    _rootView.frame = frame;
}

- (void)updateData:(id)data {
    if (data) {
        [_rootView callLua:@"updateActive" args:@[data]];
    }
}

- (void)destroyView {
    [_rootView removeFromSuperview];
    [_rootView releaseLuaView];
    _rootView = nil;
    [_nodeController removeNode:self];
}

@end
