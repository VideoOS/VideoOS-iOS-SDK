//
//  ACRCloud_Config.h
//  ACRCloud_IOS_SDK
//
//  Created by olym on 15/3/25.
//  Copyright (c) 2015年 ACRCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    rec_mode_remote = 0,    //query remote db
    rec_mode_local = 1,     //query local db
    rec_mode_both = 2,      // query both remote db and local db
    rec_mode_advance_remote = 3  //query remote db and saving recording fingerprint when offline.
}ACRCloudRecMode;

typedef enum {
    rec_data_audio = 0,     //rec audio data
    rec_data_humming = 1,   //rec humming data
    rec_data_both = 2       //rec both
}ACRCloudRecData;

typedef enum {
    result_type_error = -1,
    result_type_none = 0,
    result_type_audio = 1,
    result_type_live = 2,
    result_type_audio_live = 3,
}ACRCloudResultType;

typedef enum {
    http_resume_type_error = -1,
    http_resume_type_resume = 0,
    http_resume_type_restart = 1,
    http_resume_type_success = 2,
} HTTPResumeType;

#define ACRCLOUD_VERSION @"1.0"


typedef void(^ACRCloudResultBlock)(NSString *result, ACRCloudResultType resMode);
typedef void(^ACRCloudResultWithFpBlock)(NSString *result, NSData *fingerprint);
typedef void(^ACRCloudResultWithDataBlock)(NSString *result, NSData *data);

typedef void(^ACRCloudStateBlock)(NSString *state);

typedef void(^ACRCloudVolumeBlock)(float volume);

@interface ACRCloudConfig : NSObject
{
    NSString *_accessKey;
    NSString *_accessSecret;
    NSString *_host;
    NSString *_audioType;
    NSString *_homedir;
    NSString *_uuid;
    NSString *_protocal;
    NSDictionary *_params;
    ACRCloudRecMode _recMode;
    ACRCloudRecData _recDataType;
    NSInteger _requestTimeout;
    NSInteger _prerecorderTime;
    NSInteger _keepPlaying;
    NSUInteger _audioSessionCategory;   //default 1, support blooth and airplay
    ACRCloudResultBlock _resultBlock;
    ACRCloudStateBlock _stateBlock;
    ACRCloudVolumeBlock _volumeBlock;
    ACRCloudResultWithFpBlock _resultFpBlock;
    ACRCloudResultWithDataBlock _resultDataBlock;
}

@property(nonatomic, retain) NSString *accessKey;
@property(nonatomic, retain) NSString *accessSecret;
@property(nonatomic, retain) NSString *host;
@property(nonatomic, retain) NSString *audioType;
@property(nonatomic, retain) NSString *homedir;
@property(nonatomic, retain) NSString *uuid;
@property(nonatomic, retain) NSString *protocol;
@property(nonatomic, retain) NSDictionary *params;
@property(nonatomic, assign) ACRCloudRecMode recMode;
@property(nonatomic, assign) ACRCloudRecData recDataType;
@property(nonatomic, assign) NSInteger requestTimeout;
@property(nonatomic, assign) NSInteger prerecorderTime;
@property(nonatomic, assign) NSInteger keepPlaying;
@property(nonatomic, assign) NSUInteger audioSessionCategory;
@property(nonatomic, copy) ACRCloudResultBlock resultBlock;
@property(nonatomic, copy) ACRCloudStateBlock stateBlock;
@property(nonatomic, copy) ACRCloudVolumeBlock volumeBlock;
@property(nonatomic, copy) ACRCloudResultWithFpBlock resultFpBlock;
@property(nonatomic, copy) ACRCloudResultWithDataBlock resultDataBlock;

@end
