//
//  VPLNodeController.m
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/8/30.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLNodeController.h"
#import "VPLNativeBridge.h"
#import "VPLBaseView.h"
#import "VPLBaseNode.h"
#import "VPLClickThroughView.h"
#import "VPLNetworkManager.h"
#import "VPLVideoInfo.h"

#import "VPUPValidator.h"
#import "VPUPPathUtil.h"
#import "VPUPPrefetchManager.h"
#import "VPUPNotificationCenter.h"
#import "VPUPHTTPManagerFactory.h"
#import "VPUPLoadImageFactory.h"
#import "VPUPActionManager.h"
#import "VPUPHTTPAPIManager.h"
#import "VPUPLoadImageManager.h"
#import "VPUPMD5Util.h"
#import "VPLVideoPlayerSize.h"
#import "VPUPRandomUtil.h"

#import <VPLuaViewSDK/LuaViewCore.h>
#import "VideoPlsUtilsPlatformSDK.h"
#import "VPLConstant.h"

//cont
//static NSMutableArray<VPLNodeController *> *avaliableControllers;

@interface VPLNodeController()

@property (nonatomic,strong) VPLClickThroughView *rootView;
//@property (nonatomic) NSPointerArray *natives;
@property (nonatomic) NSMutableArray<VPLBaseNode *> *nodes;

@property (nonatomic) VPLNetworkManager *networkManager;

@property (nonatomic, weak) NSDictionary *(^getUserInfoBlock)(void);

@end

@implementation VPLNodeController {
    CGRect _playerRect;
    CGRect _videoRect;
//    NSString *_destinationPath;
    VPUPPrefetchManager *_prefetchManager;
    
    id<VPUPHTTPAPIManager> _httpManager;
    id<VPUPLoadImageManager> _imageManager;
}

+ (void)initialize {
    [[VPUPRoutes routesForScheme:@"turn"] addRoute:@"/:path" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        
        VPLNodeController *controller = [[parameters objectForKey:VPUPRouteUserInfoKey] objectForKey:@"ActionManagerSender"];
        if ([controller isKindOfClass:[VPLNodeController class]]) {
            [controller turnActionWithFileName:[parameters objectForKey:@"path"] data:parameters];
        }
        return YES;
    }];
    [[VPUPRoutes routesForScheme:@"turnOff"] addRoute:@"/:path" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        
        VPLNodeController *controller = [[parameters objectForKey:VPUPRouteUserInfoKey] objectForKey:@"ActionManagerSender"];
        if ([controller isKindOfClass:[VPLNodeController class]]) {
            [controller turnOffRouteParam:parameters];
        }
        return YES;
    }];
}

+ (void)saveLFileWithUrl:(NSString *)url md5:(NSString *)md5 {
    
    if(!url || [url isEqualToString:@""]) {
        return;
    }
    
    VPUPPrefetchManager *prefetchManager = [[VPUPPrefetchManager alloc] init];
    NSString *destinationPath = [VPUPPathUtil lPath];
    
    NSString *fileName = [url lastPathComponent];
    if(!md5) {
        //没有md5, 判断本地不存在则下载
        NSString *filePath = [destinationPath stringByAppendingPathComponent:fileName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            return;
        }
    }
    else {
        //TODO: 开发时不从线上下载
//        return;
        
        //存在md5, 要对文件进行校验
        NSString *filePath = [destinationPath stringByAppendingPathComponent:fileName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            
            long long size = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil].fileSize;
            
            NSString *localMD5 = [VPUPMD5Util md5File:filePath size:size];
            
            if([localMD5 isEqualToString:md5]) {
                //md5 一致
                return;
            }
            else {
                //移除后下载
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
    }
    
    [prefetchManager prefetchURLs:@[url] fileNames:@[fileName] destinationPath:destinationPath completionBlock:^(NSUInteger numberOfFinishedUrls, NSUInteger numberOfSkippedUrls) {

    }];
    
}



- (instancetype)init {
    return [self initWithViewFrame:CGRectZero videoRect:CGRectZero];
}

- (instancetype)initWithViewFrame:(CGRect)frame videoRect:(CGRect)videoRect {
    return [self initWithViewFrame:frame videoRect:videoRect networkManager:nil videoInfo:nil];
}

- (instancetype)initWithViewFrame:(CGRect)frame
                        videoRect:(CGRect)videoRect
                   networkManager:(VPLNetworkManager *)networkManager
                        videoInfo:(VPLVideoInfo *)videoInfo {
    self = [super init];
    if(self) {
        _playerRect = frame;
        _videoRect = videoRect;
        _rootView = [[VPLClickThroughView alloc] initWithFrame:frame];
        
        _networkManager = networkManager;
        _videoInfo = videoInfo;
        
        if(!_networkManager) {
            [self initNetworkManager];
        }
        
        _destinationPath = [VPUPPathUtil lPath];
        _prefetchManager = [[VPUPPrefetchManager alloc] init];
        [self registerActionNotification];
//        _natives = [NSPointerArray weakObjectsPointerArray];
//        if(!avaliableControllers) {
//            avaliableControllers = [NSMutableArray array];
//        }
//        [avaliableControllers addObject:self];
        
        _nodes = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc {
    
}

- (void)setGetUserInfoBlock:(NSDictionary *(^)(void))userInfoBlock {
    if(userInfoBlock) {
        _getUserInfoBlock = userInfoBlock;
    }
}

- (void)initNetworkManager {
    _httpManager = [VPUPHTTPManagerFactory createHTTPAPIManagerWithType:VPUPHTTPManagerTypeAFN];
    _imageManager = [VPUPLoadImageFactory createWebImageManagerWithType:VPUPWebImageManagerTypeSD];
    
    _networkManager = [[VPLNetworkManager alloc] init];
    _networkManager.httpManager = _httpManager;
    _networkManager.imageManager = _imageManager;
}

- (void)changeDestinationPath:(NSString *)destinationPath {
    if(VPUP_IsStringTrimExist(destinationPath)) {
        _destinationPath = destinationPath;
    }
}

- (void)loadLFile:(NSString *)luaUrl data:(id)data {
    NSURL *url = nil;
    
    //移除远程下载代码，默认走本地文件
    
//    BOOL isRemoteUrl = NO;
//    if([luaUrl rangeOfString:@"http"].location != NSNotFound) {
//        url = [[NSURL alloc] initWithString:luaUrl];
//        isRemoteUrl = YES;
//    }
//    else {
        url = [NSURL fileURLWithPath:luaUrl];
//    }
    
    if (!url) {
        return;
    }
    
//    if (isRemoteUrl) {
//        [self loadRemoteLua:url data:data];
//    } else {
        NSString *fileName = [url path];
        [self turnActionWithFileName:fileName data:data];
//    }
}

//- (void)loadRemoteLua:(nonnull NSURL *)url data:(id)data {
//
//    NSString *fileName = [url lastPathComponent];
//    __block NSString *filePath = [_destinationPath stringByAppendingPathComponent:fileName];
//
//    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//        [self turnActionWithFileName:filePath data:data];
//        return;
//    }
//    __weak __typeof(self)weakSelf = self;
//
//    [_prefetchManager prefetchURLs:@[url.absoluteString] fileNames:@[fileName] destinationPath:_destinationPath completionBlock:^(NSUInteger numberOfFinishedUrls, NSUInteger numberOfSkippedUrls) {
//        if(numberOfFinishedUrls > 0) {
//            [weakSelf turnActionWithFileName:filePath data:data];;
//        }
//    }];
//}


- (void)turnActionWithFileName:(NSString *)fileName data:(NSDictionary *)parameters {
    
    if(!VPUP_IsExist(fileName)) {
        //无lua文件
        return;
    }
    
    NSString *filePath = fileName;
    
    //可能为sendAction
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSString *trueFilePath = [_destinationPath stringByAppendingPathComponent:filePath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:trueFilePath]) {
            //no file exist
            
            return;
        }
        else {
            filePath = trueFilePath;
        }
    }
    
    NSDictionary *queryParams = [parameters objectForKey:VPUPRouteQueryParamsKey];
    NSDictionary *luaData = nil;
    if ([[parameters objectForKey:VPUPRouteUserInfoKey] objectForKey:@"ActionManagerData"]) {
        luaData = [[parameters objectForKey:VPUPRouteUserInfoKey] objectForKey:@"ActionManagerData"];
    }
    else if ([[parameters objectForKey:VPUPRouteUserInfoKey] objectForKey:@"ActionManagerSender"]) {
        luaData = nil;
    }
    else {
        //不是从sendAction来的数据
        luaData = [parameters objectForKey:VPUPRouteUserInfoKey];
    }

    NSString *nodeId = [queryParams objectForKey:@"id"];
    if (!nodeId) {
        nodeId = [luaData objectForKey:@"id"];

        if (!nodeId) {
            NSString *random = [VPUPRandomUtil randomStringByLength:4];
            nodeId = [NSString stringWithFormat:@"root_%@", random];
        }
    }
    
    NSDictionary *miniAppInfo = [luaData objectForKey:@"miniAppInfo"];
    NSString *developerUserId = @"10001001000";
    NSString *mpID = @"";
    if (miniAppInfo && [miniAppInfo objectForKey:@"developerUserId"] != nil) {
        developerUserId = [miniAppInfo objectForKey:@"developerUserId"];
    }
    if (miniAppInfo && [miniAppInfo objectForKey:@"miniAppId"] != nil) {
        mpID = [miniAppInfo objectForKey:@"miniAppId"];
    }
    
    
    NSMutableDictionary *toLuaData = [NSMutableDictionary dictionaryWithCapacity:0];
    [toLuaData addEntriesFromDictionary:queryParams];
    if (luaData && luaData.count > 0) {
        [toLuaData setObject:luaData forKey:@"data"];
    }
    
    if (nodeId) {
        for (VPLBaseNode *tempNode in _nodes) {
            if ([tempNode.nodeId isEqualToString:nodeId]) {
                [tempNode callMethod:@"show" data:toLuaData];
                return;
            }
        }
    }
    
    VPLBaseNode *node = [self createNode];
    node.nodeId = nodeId;
    [node.lvCore.bundle changeCurrentPath:[filePath stringByDeletingLastPathComponent]];
    [node.lvCore.bundle addScriptPath:@".."];
    node.videoPlayerSize = self.videoPlayerSize;
    node.videoInfo = _videoInfo;
    node.networkManager = _networkManager;
    node.getUserInfoBlock = _getUserInfoBlock;
    node.nodeController = self;
    node.lFile = filePath;
    node.rootView.frame = _rootView.bounds;
    node.developerUserId = developerUserId;
    node.mpID = mpID;
    
    if ([toLuaData objectForKey:@"priority"]) {
        node.priority = [[toLuaData objectForKey:@"priority"] integerValue];
    } 

    NSString *runFile = [node runLuaFile:filePath data:toLuaData];

    if(runFile) {
        VPUPLogW(@"[load lua error], error:%@", runFile);
        [VPUPActionManager pushAction:VPUP_SchemeAddPath(@"error", @"Lua") data:node.lFile sender:self];
        if (self.nodeDelegate && [self.nodeDelegate respondsToSelector:@selector(loadLFileError:)]) {
            [self.nodeDelegate loadLFileError:runFile];
        }
        return;
    }
    //页面按优先级添加
    NSInteger insertIndex = _nodes.count;
    for (VPLBaseNode *tempNode in _nodes) {
        if (tempNode.priority > node.priority) {
            insertIndex -= 1;
        }
    }
    [_rootView insertSubview:node.rootView atIndex:insertIndex];
    [_nodes addObject:node];
}

- (void)callLMethod:(NSString *)method data:(id)data {
    for (VPLBaseNode *tempNode in _nodes) {
        [tempNode callMethod:method data:data];
    }
}

- (void)callLMethod:(NSString *)method nodeId:(NSString *)nodeId data:(id)data {
    if (nodeId == nil) {
        [self callLMethod:method data:data];
    }
    else {
        for (VPLBaseNode *tempNode in _nodes) {
            if ([tempNode.nodeId isEqualToString:nodeId]) {
                [tempNode callMethod:method data:data];
            }
        }
    }
}

- (void)removeNodeWithNodeId:(NSString *)nodeId {
    VPLBaseNode *removeNode = nil;
    for (VPLBaseNode *tempNode in _nodes) {
        if ([tempNode.nodeId isEqualToString:nodeId]) {
            removeNode = tempNode;
        }
    }
    if (removeNode) {
        [removeNode destroyView];
    }
}

- (void)removeLastNode {
    VPLBaseNode *removeNode = [_nodes lastObject];
    if (removeNode == [_nodes firstObject]) {
        //已经是最后一个了,不移除
        return;
    }
    [removeNode destroyView];
    
}

- (void)turnOffNode:(NSNotification *)sender {
    NSDictionary *userInfo = sender.userInfo;
    if (![userInfo objectForKey:@"path"]) {
        return;
    }
    NSString *path = [userInfo objectForKey:@"path"];
    NSDictionary *data = nil;
    if ([userInfo objectForKey:@"data"]) {
        data = [userInfo objectForKey:@"data"];
    }
    BOOL needDeleteAll = NO;
    if ([data objectForKey:@"data"]) {
        NSString *dataString = [data objectForKey:@"data"];
        if ([dataString isEqualToString:@"all"]) {
            needDeleteAll = YES;
        }
    }
    
    NSMutableArray *pathNodes = [NSMutableArray array];
    
    NSString *nodeId = [data objectForKey:@"id"];
    
    [_nodes enumerateObjectsUsingBlock:^(VPLBaseNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj.lFile lastPathComponent] isEqualToString:path]) {
            [pathNodes addObject:obj];
        }
        if ([obj.nodeId isEqualToString:nodeId] && ![pathNodes containsObject:obj]) {
            [pathNodes addObject:obj];
        }
    }];
    
    if ([pathNodes count] == 0) {
        return;
    }
    
    if (needDeleteAll) {
        [pathNodes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [obj destroyView];
            });
        }];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[pathNodes firstObject] destroyView];
        });
    }
}

- (void)turnRouteData:(id)data {
    
}

- (void)turnOffRouteParam:(id)param {
    
    id data = [[param objectForKey:VPUPRouteUserInfoKey] objectForKey:@"ActionManagerData"];
    if (!data) {
        data = [param objectForKey:VPUPRouteUserInfoKey];
    }
    
    NSMutableArray *pathNodes = [NSMutableArray array];
    
    NSString *nodeId = [data objectForKey:@"id"];
    
    [_nodes enumerateObjectsUsingBlock:^(VPLBaseNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.nodeId isEqualToString:nodeId]) {
            [pathNodes addObject:obj];
        }
    }];
    
    if ([pathNodes count] == 0) {
        return;
    }
    
    [pathNodes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [obj destroyView];
        });
    }];
}

- (VPLBaseNode*)createNode {
    VPLBaseNode *node = [[VPLBaseNode alloc] init];
    return node;
}

- (void)removeNode:(VPLBaseNode *)node {
    if([_nodes containsObject:node]) {
        [_nodes removeObject:node];
        [VPUPActionManager pushAction:VPUP_SchemeAddPath(@"end", @"Lua") data:[[node lFile] lastPathComponent] sender:self];
    }
}

- (void)updateFrame:(CGRect)frame isPortrait:(BOOL)isPortrait isFullScreen:(BOOL)isFullScreen {
    [self.rootView setFrame:frame];
    _portrait = isPortrait;
    _fullScreen = isFullScreen;
    __weak typeof(self.rootView) weakView = self.rootView;
    
    [_nodes enumerateObjectsUsingBlock:^(VPLBaseNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [obj updateFrame:weakView.bounds isPortrait:isPortrait isFullScreen:isFullScreen];
        });
    }];
}

- (void)updateData:(id)data {
    
    [_nodes enumerateObjectsUsingBlock:^(VPLBaseNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [obj updateData:data];
        });
    }];
}

- (void)releaseLuaView {
    [_nodes enumerateObjectsUsingBlock:^(VPLBaseNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [obj destroyView];
        });
    }];
    
    [self deregisterActionNotification];
    
    _getUserInfoBlock = nil;
    _httpManager = nil;
    _imageManager = nil;
    _networkManager = nil;
    _videoInfo = nil;
}

- (void)registerActionNotification {
    [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOffNode:) name:VPUPActionTurnOffNotification object:self];
}

- (void)deregisterActionNotification {
    [[VPUPNotificationCenter defaultCenter] removeObserver:self name:VPUPActionTurnOffNotification object:self];
}

- (void)closeActionWebViewForAd:(NSString *)adId {
    for (VPLBaseNode *tempNode in _nodes) {
        if ([tempNode.nodeId isEqualToString:adId]) {
            [tempNode callMethod:@"show" data:nil];
            return;
        }
    }
}

- (void)playVideoAd {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    for (VPLBaseNode *tempNode in _nodes) {
        if (tempNode.priority == VPLBaseNodeWedgePriority) {
            [array addObject:tempNode];
        }
    }
    if (array.count > 0) {
        for (VPLBaseNode *tempNode in array) {
            [tempNode callMethod:@"show" data:nil];
        }
    }
}

- (void)closeInfoView {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    for (VPLBaseNode *tempNode in _nodes) {
        if (tempNode.priority == VPLBaseNodeInfoViewPriority) {
            [array addObject:tempNode];
        }
    }
    if (array.count > 0) {
        for (VPLBaseNode *tempNode in array) {
            [tempNode destroyView];
        }
    }
}

@end
