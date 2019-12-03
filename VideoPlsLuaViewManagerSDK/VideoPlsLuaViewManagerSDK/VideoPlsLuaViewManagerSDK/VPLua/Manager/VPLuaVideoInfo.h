//
//  VPLuaVideoInfo.h
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/9/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPLuaVideoInfo : NSObject <NSCopying>

@property (nonatomic, copy) NSString *nativeID;         //mainID, videoID or platformUserID(roomID)
@property (nonatomic, copy) NSString *platformID;       //subID, for platformInfo like:mango's ID, pandatv's ID
@property (nonatomic, copy) NSString *ssid;             //打开货架时生成 identity+unixtime+random(三个字母)
@property (nonatomic, copy) NSString *projectID;
@property (nonatomic, copy) NSString *channelID;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *extendJSONString;
@property (nonatomic, copy) NSString *episode;
@property (nonatomic, copy) NSString *title;

- (NSDictionary *)dictionaryValue;

@end
