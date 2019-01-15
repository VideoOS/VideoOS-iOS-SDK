//
//  VPUPDefaultRoutesRegister.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 05/02/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPDefaultRoutesRegister.h"
#import "VPUPRoutes.h"
#import <objc/runtime.h>
#import "VPUPTopViewController.h"
#import "VPUPRoutesConstants.h"
#import <UIKit/UIKit.h>
#import "VPUPJsonUtil.h"

@implementation VPUPDefaultRoutesRegister

+ (void)load {
    [[VPUPRoutes routesForScheme:VPUPRoutesSDKNativeView] addRoute:@"/show/:view" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        Class class = NSClassFromString(parameters[@"view"]);
        UIView *view = [[class alloc] initWithFrame:CGRectZero];
        view.frame = CGRectMake(0,0,100,100);
        if ([parameters objectForKey:@"frame"]) {
            NSArray *array = (NSArray*)VPUP_JsonToDictionary([parameters objectForKey:@"frame"]);
            NSLog(@"%@",array);
            view.frame = CGRectMake([array[0] doubleValue],[array[1] doubleValue],[array[2] doubleValue],[array[3] doubleValue]);
        }
        
        if ([parameters objectForKey:VPUPRouteUserInfoKey]) {
            NSDictionary *keyValueDic = [parameters objectForKey:VPUPRouteUserInfoKey];
            [keyValueDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSObject *obj, BOOL *stop){
                @try {
                    if ([key isEqualToString:VPUPRoutesRootView]) {
                        UIView *rootView = (UIView*)obj;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [rootView addSubview:view];
                        });
                    }
                    else {
                        [view setValue:obj forKey:key];
                    }
                } @catch (NSException *exception) {
                    NSLog(@"error key : %@, value : %@",key,obj);
                }
            }];
        }
        [self paramToObject:view param:parameters];
        return YES;
    }];
    [[VPUPRoutes routesForScheme:VPUPRoutesSDKNavigationPage] addRoute:@"/present/:controller" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        Class class = NSClassFromString(parameters[@"controller"]);
        UIViewController *viewController = [[class alloc] init];
        
        [self paramToObject:viewController param:parameters];
        [[VPUPTopViewController topViewController] presentViewController:viewController animated:YES completion:nil];
        return YES;
    }];
    [[VPUPRoutes routesForScheme:VPUPRoutesSDKNavigationPage] addRoute:@"/push/:controller" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        Class class = NSClassFromString(parameters[@"controller"]);
        UIViewController *viewController = [[class alloc] init];
        
        [self paramToObject:viewController param:parameters];
        
        return YES;
    }];
}

//传参数
+ (void)paramToObject:(NSObject *)object param:(NSDictionary<NSString *, id> *)parameters{
    unsigned int outCount = 0;
    objc_property_t * properties = class_copyPropertyList(object.class , &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = [NSString stringWithUTF8String:property_getName(property)];
        NSLog(@"UIView property : %@",key);
        NSString *param = parameters[key];
        if (param != nil) {
            [object setValue:param forKey:key];
        }
    }
}

@end
