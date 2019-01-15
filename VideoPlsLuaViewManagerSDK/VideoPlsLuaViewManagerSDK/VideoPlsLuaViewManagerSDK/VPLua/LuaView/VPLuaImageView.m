//
//  VPLuaImageView.h
//  VideoPlsLuaViewSDK
//
//  Created by 鄢江波 on 2017/8/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLuaImageView.h"
#import "VPUPLoadImageFactory.h"
#import "VPUPLoadImageBaseConfig.h"
#import "VPUPLoadImageManager.h"
#import "VPUPBase64Util.h"

#import "VPLuaNativeBridge.h"
//#import "VPMGoodsListLoadingImage.h"

#import "LVData.h"
#import "LVBitmap.h"
#import "LVBaseView.h"
#import "LVNinePatchImage.h"


static NSString *const VPDefaultImageBundle = @"VideoPlsDefaultImages";

@interface VPLuaImageView()

@property (nonatomic, strong) id functionTag;
@property (nonatomic, assign) BOOL needCallLuaFunc;
@property (nonatomic, strong) id errorInfo;
@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;
@property (nonatomic, assign) BOOL lv_isCallbackAddClickGesture;// 支持Callback 点击事件
@property (nonatomic, strong) UIVisualEffectView *effectView;

@end

@implementation VPLuaImageView {
    __weak id<VPUPLoadImageManager> _manager;
}

-(id) init:(lua_State*) l{
    self = [super init];
    if( self ){
        self.lv_luaviewCore = LV_LUASTATE_VIEW(l);
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.functionTag = [[NSMutableString alloc] init];
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.lv_isCallbackAddClickGesture = YES;
//        self.disableAnimate = self.lv_luaviewCore.disableAnimate;
        
        _manager = [VPLuaNativeBridge luaNodeFromLuaState:l].networkManager.imageManager;
    }
    return self;
}

-(void) callLuaDelegate:(id) obj{
    lua_State* L = self.lv_luaviewCore.l;
    if( L ) {
        lua_checkstack(L, 4);
        lua_pushboolean(L, obj?0:1);
        [LVUtil pushRegistryValue:L key:self.functionTag];
        lv_runFunctionWithArgs(L, 1, 0);
    }
    [LVUtil unregistry:L key:self.functionTag];
}

-(void) setWebImageUrl:(NSURL *)url finished:(LVLoadFinished)finished {
    VPUPLoadImageBaseConfig *config = [[VPUPLoadImageBaseConfig alloc] init];
    config.url = url;
    config.view = self;
    
    if (self.image) {
        config.options = VPUPWebImageDelayPlaceholder;
        config.placeholderContentMode = UIViewContentModeScaleAspectFill;
        config.placeholder = self.image;
    }
    
//    config.placeholder = [VPMGoodsListLoadingImage loadingImage];
    config.completedBlock = ^(UIImage *image, NSError *error, VPUPImageCacheType cacheType, NSURL *imageURL) {
        if (finished) {
            finished(error);
        }
    };
    [_manager loadImageWithConfig:config];
}

-(void) setImageByName:(NSString*) imageName{
    if( imageName == nil )
        return;
    
    if( [LVUtil isExternalUrl:imageName] ){
        //CDN image
        __weak VPLuaImageView* weakImageView = self;
        [self setWebImageUrl:[NSURL URLWithString:imageName] finished:^(id errorInfo){
            if( weakImageView.needCallLuaFunc ) {
                weakImageView.errorInfo = errorInfo;
                [weakImageView performSelectorOnMainThread:@selector(callLuaDelegate:) withObject:errorInfo waitUntilDone:NO];
            }
        }];
    } else {
        // local Image
        UIImage* image = [self.lv_luaviewCore.bundle imageWithName:imageName];
        if (image) {
            if ( [LVNinePatchImage isNinePathImageName:imageName] ) {
                image = [LVNinePatchImage createNinePatchImage:image];
                [self setImage:image];
            } else {
                [self setImage:image];
            }
        }
    }
}

-(void) lv_effectParallax:(CGFloat)dx dy:(CGFloat)dy{
    [self effectParallax:dx dy:dy];
}

-(void) effectParallax:(CGFloat)dx dy:(CGFloat)dy {
}

-(void) effectClick:(NSInteger)color alpha:(CGFloat)alpha {
}

-(void) setImageByData:(NSData*) data{
    if ( data ) {
        UIImage* image = [[UIImage alloc] initWithData:data];
        [self setImage:image];
    }
}

-(void) canelWebImageLoading{
    // [self cancelCurrentImageLoad]; // 取消上一次CDN加载
}

-(void) cancelImageLoadAndClearCallback:(lua_State*)L{
    [self canelWebImageLoading];
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // 取消回调脚本
    [LVUtil unregistry:L key:self.functionTag]; // 清除脚本回调
}

-(void) dealloc{
    LVUserDataInfo* userData = self.lv_userData;
    if( userData ){
        userData->object = NULL;
    }
}

- (UIImage *)imageFromBundleWithName:(NSString *)imageName {
    
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:VPDefaultImageBundle withExtension:@"bundle"];
    if (bundleURL) {
        NSBundle *imageBundle = [NSBundle bundleWithURL:bundleURL];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            return [UIImage imageNamed:imageName inBundle:imageBundle compatibleWithTraitCollection:nil];
        }
        else {
            NSString *file = [imageBundle pathForResource:[NSString stringWithFormat:@"%@@2x", imageName] ofType:@"png"];
            return [UIImage imageWithContentsOfFile:file];
        }
    }
    
    return nil;
}

- (void) layoutSubviews{
    [super layoutSubviews];
    if (self.effectView) {
        self.effectView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
}

static int lvNewImageView(lua_State *L) {
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLuaImageView class]];
    
    NSString* imageName = lv_paramString(L, 1);
    
    VPLuaImageView* imageView = [[c alloc] init:L];
    [imageView setImageByName:imageName];
    {
        NEW_USERDATA(userData, View);
        userData->object = CFBridgingRetain(imageView);
        imageView.lv_userData = userData;
        
        luaL_getmetatable(L, META_TABLE_UIImageView );
        lua_setmetatable(L, -2);
    }
    LuaViewCore* view = LV_LUASTATE_VIEW(L);
    if( view ){
        [view containerAddSubview:imageView];
    }
    return 1; /* new userdatum is already on the stack */
}

static int setImage (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaImageView* imageView = (__bridge VPLuaImageView *)(user->object);
        if ( [imageView isKindOfClass:[VPLuaImageView class]] ) {
            [imageView cancelImageLoadAndClearCallback:L];
            if( lua_type(L, 3) == LUA_TFUNCTION ) {
                [LVUtil registryValue:L key:imageView.functionTag stack:3];
                imageView.needCallLuaFunc = YES;
            } else {
                imageView.needCallLuaFunc = NO;
            }
            if ( lua_type(L, 2)==LUA_TSTRING ) {
                NSString* imageName = lv_paramString(L, 2);// 2
                if( imageName ){
                    [imageView setImageByName:imageName];
                    lua_pushvalue(L,1);
                    return 1;
                }
            } else if ( lua_type(L, 2)==LUA_TUSERDATA ) {
                LVUserDataInfo * userdata = (LVUserDataInfo *)lua_touserdata(L, 2);
                if( LVIsType(userdata, Data) ) {
                    LVData* lvdata = (__bridge LVData *)(userdata->object);
                    [imageView setImageByData:[VPUPBase64Util dataBase64DecodeFromString:[[NSString alloc] initWithData:lvdata.data encoding:NSUTF8StringEncoding]]];
                    lua_pushvalue(L,1);
                    return 1;
                } else if( LVIsType(userdata, Bitmap) ) {
                    LVBitmap* bitmap = (__bridge LVBitmap *)(userdata->object);
                    [imageView setImage:bitmap.nativeImage];
                    lua_pushvalue(L,1);
                    return 1;
                }
            } else {
                // 清理图片
                imageView.image = nil;
            }
        }
    }
    return 0;
}

static int scaleType (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaImageView* imageView = (__bridge VPLuaImageView *)(user->object);
        if ( [imageView isKindOfClass:[VPLuaImageView class]] ) {
            if( lua_gettop(L)>=2 ) {
                int model = lua_tonumber(L, 2);// 2
                [imageView setContentMode:model];
                return 0;
            } else {
                UIViewContentMode model = imageView.contentMode;
                lua_pushnumber(L, model);
                return 1;
            }
        }
    }
    return 0;
}

static int placeHolderImage(lua_State* L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaImageView* imageView = (__bridge VPLuaImageView *)(user->object);
        if ( [imageView isKindOfClass:[VPLuaImageView class]] ) {
            if( lua_gettop(L)>=2 ) {
                if (lua_type(L, 2)==LUA_TSTRING) {
                    NSString *placeholderName = lv_paramString(L, 2);
                    if (placeholderName && ![placeholderName isEqualToString:@""]) {
                        imageView.image = [imageView imageFromBundleWithName:placeholderName];
                    }
                    lua_pushvalue(L,1);
                    return 1;
                }
                else if ( lua_type(L, 2)==LUA_TUSERDATA ) {
                    LVUserDataInfo * userdata = (LVUserDataInfo *)lua_touserdata(L, 2);
                    if( LVIsType(userdata, Data) ) {
                        LVData* lvdata = (__bridge LVData *)(userdata->object);
                        [imageView setImageByData:[VPUPBase64Util dataBase64DecodeFromString:[[NSString alloc] initWithData:lvdata.data encoding:NSUTF8StringEncoding]]];
                        lua_pushvalue(L,1);
                        return 1;
                    } else if( LVIsType(userdata, Bitmap) ) {
                        LVBitmap* bitmap = (__bridge LVBitmap *)(userdata->object);
                        [imageView setImage:bitmap.nativeImage];
                        lua_pushvalue(L,1);
                        return 1;
                    }
                }
            }
        }
    }
    return 0;
}


+(int) lvClassDefine:(lua_State *)L globalName:(NSString*) globalName{
    
    [LVUtil reg:L clas:self cfunc:lvNewImageView globalName:globalName defaultName:@"Image"];
    
    const struct luaL_Reg memberFunctions [] = {
        {"image",  setImage},
        {"scaleType",  scaleType},
        {"placeHolderImage", placeHolderImage},
        {"stretch", stretch},
        {"capInsets", capInsets},
        {"imageBlur", imageBlur},
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L, META_TABLE_UIImageView);
    
    luaL_openlib(L, NULL, [LVBaseView baseMemberFunctions], 0);
    luaL_openlib(L, NULL, memberFunctions, 0);
    
    const char* keys[] = { "addView", NULL};// 移除多余API
    lv_luaTableRemoveKeys(L, keys );
    return 1;
}

- (id)lv_nativeObject {
    return self;
}

static int stretch (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaImageView* imageView = (__bridge VPLuaImageView *)(user->object);
        if ( [imageView isKindOfClass:[VPLuaImageView class]] ) {
            if (lua_gettop(L) >= 3 && imageView.image) {
                NSInteger leftWidth = lua_tointeger(L, 2);
                NSInteger topHeight = lua_tointeger(L, 3);
                UIImage *tempImage = [imageView.image stretchableImageWithLeftCapWidth:leftWidth topCapHeight:topHeight];
                imageView.image = tempImage;
            }
        }
    }
    return 0;
}

static int capInsets (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaImageView* imageView = (__bridge VPLuaImageView *)(user->object);
        if ( [imageView isKindOfClass:[VPLuaImageView class]] ) {
            if (lua_gettop(L) >= 5 && imageView.image) {
                //top, left, bottom, right
                CGFloat top = lua_tonumber(L, 2);
                CGFloat left = lua_tonumber(L, 3);
                CGFloat bottom = lua_tonumber(L, 4);
                CGFloat right = lua_tonumber(L, 5);
                UIEdgeInsets capInsets = UIEdgeInsetsMake(top, left, bottom, right);
                UIImage *tempImage = [imageView.image resizableImageWithCapInsets:capInsets];
                imageView.image = tempImage;
            }
        }
    }
    return 0;
}

static int imageBlur (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaImageView* imageView = (__bridge VPLuaImageView *)(user->object);
        if ( [imageView isKindOfClass:[VPLuaImageView class]] ) {
            [imageView cancelImageLoadAndClearCallback:L];
            if( lua_type(L, 4) == LUA_TFUNCTION ) {
                [LVUtil registryValue:L key:imageView.functionTag stack:4];
                imageView.needCallLuaFunc = YES;
            } else {
                imageView.needCallLuaFunc = NO;
            }
            if ( lua_type(L, 2) == LUA_TSTRING ) {
                NSString* imageName = lv_paramString(L, 2);// 2
                if( imageName ){
                    [imageView setImageByName:imageName];
                }
            } else if ( lua_type(L, 2) == LUA_TUSERDATA ) {
                LVUserDataInfo * userdata = (LVUserDataInfo *)lua_touserdata(L, 2);
                if( LVIsType(userdata, Data) ) {
                    LVData* lvdata = (__bridge LVData *)(userdata->object);
                    [imageView setImageByData:[VPUPBase64Util dataBase64DecodeFromString:[[NSString alloc] initWithData:lvdata.data encoding:NSUTF8StringEncoding]]];
                } else if( LVIsType(userdata, Bitmap) ) {
                    LVBitmap* bitmap = (__bridge LVBitmap *)(userdata->object);
                    [imageView setImage:bitmap.nativeImage];
                }
            }
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
            effectView.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
            [imageView addSubview:effectView];
            imageView.effectView = effectView;
            lua_pushvalue(L,1);
            return 1;
        }
    }
    return 0;
}

@end
