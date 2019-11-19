//
//  DevAppTool.m
//  VideoOSDevApp
//
//  Created by videopls on 2019/10/11.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "DevAppTool.h"

@implementation DevAppTool


+ (void)writeUserDataWithKey:(id)data forKey:(NSString*)key
{
    if (data == nil)
    {
        return;
    }
    
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
 
//读取用户偏好设置
+ (id)readUserDataWithKey:(NSString*)key
{
    id temp = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if(temp != nil)
    {
        return temp;
    }
    
    return nil;
}
 
//删除用户偏好设置
+ (void)removeUserDataWithkey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}


+ (NSBundle *)devAPPBundle{
    NSString * bundlePath = [[ NSBundle mainBundle] pathForResource: @ "DevAppResource"ofType :@ "bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return bundle;
}

+ (void)copyLuaFile:(NSString*)bundlePath ToFilePath:(NSString*)destinationPath{
    
    NSLog(@"");
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL isExist = [fileManger fileExistsAtPath:bundlePath isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:bundlePath error:nil];
            NSString * subPath = nil;
            for (NSString * str in dirArray) {
                
                
                
                if ([str hasSuffix:@".lua"]) {
                    
                    // copy
                    subPath  = [bundlePath stringByAppendingPathComponent:str];
                    
                    
                    BOOL isSubExist = [fileManger fileExistsAtPath:[destinationPath stringByAppendingPathComponent:str] isDirectory:nil];
                    if ((isSubExist && [str hasSuffix:@".json"]) || TARGET_IPHONE_SIMULATOR != 1) {
                        [fileManger removeItemAtPath:[destinationPath stringByAppendingPathComponent:str] error:nil];
                    }
                    NSError* error = nil;
                    [fileManger copyItemAtPath:subPath toPath:[destinationPath stringByAppendingPathComponent:str] error:&error];
                    if (error) {
                        NSLog(@"copy error %@",error);
                    }
                    

                }
                
                
                ;
            }
        }else{
            NSLog(@"this path is not isDir!");
            NSError* error = nil;
            BOOL isSubExist = [fileManger fileExistsAtPath:destinationPath isDirectory:nil];
            if ((isSubExist && [destinationPath hasSuffix:@".json"]) || TARGET_IPHONE_SIMULATOR != 1) {
                [fileManger removeItemAtPath:destinationPath error:nil];
            }
            [fileManger copyItemAtPath:bundlePath toPath:destinationPath error:&error];
            if (error) {
                NSLog(@"copy error %@",error);
            }

        }
    }else{
        NSLog(@"this path is not exist!");
    }
    
}

+ (NSString*)getInteractionLuaPath{

    return  [[[DevAppTool devAPPBundle].bundlePath stringByAppendingPathComponent:@"interactionLua"] stringByAppendingPathComponent:@""];
}

@end
