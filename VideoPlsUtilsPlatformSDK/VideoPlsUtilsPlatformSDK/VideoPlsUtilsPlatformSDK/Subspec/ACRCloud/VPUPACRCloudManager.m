//
//  VPUPACRCloudManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by videopls on 2020/2/25.
//  Copyright © 2020 videopls. All rights reserved.
//

#import "VPUPACRCloudManager.h"
#import "ACRCloudConfig.h"
#import "ACRCloudRecognition.h"
#import <AVFoundation/AVFoundation.h>
#import "VPUPServiceManager.h"

@implementation VPUPACRCloudManager

+ (void)load {
    [[VPUPServiceManager sharedManager] registerService:@protocol(VPUPACRCloudAPIManager) implClass:[VPUPACRCloudManager class]];
}

+ (void)acrRecognitionMusic:(NSString*_Nullable)path key:(NSString*_Nullable)key secret:(NSString*_Nullable)secret  callback:(VPUPACRMusicInfoCallback _Nonnull)musicInfoCallback{
    
    
    NSData* audiData = [NSData dataWithContentsOfFile:path];
    
    NSError* error;
    NSDictionary* status = [NSDictionary dictionaryWithObjectsAndKeys:@-1000,@"code", nil];
    NSDictionary* errorDic = [NSDictionary dictionaryWithObjectsAndKeys:status,@"status", nil];
    
    AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithData:audiData error:&error];
    if (error) {
        musicInfoCallback(errorDic);
        return;
    }
    NSString* fileExtension = [[path pathExtension] lowercaseString];
    if (![fileExtension isEqualToString:@"wav"]) {
        NSLog(@"lingting error file is not wav");
        musicInfoCallback(errorDic);
        return;
    }
    
    
    if (player.numberOfChannels != 1) {
        NSLog(@"lingting error channelCount is not 1");
        musicInfoCallback(errorDic);
        return;
    }
    
    
    
    if (@available(iOS 10.0, *)) {
        AVAudioFormat* format = player.format;
        
        if (format.sampleRate != 8000) {
            NSLog(@"lingting error sampleRate is not 8000HZ");
            musicInfoCallback(errorDic);
            return;
        }
        
        if (format.commonFormat != AVAudioPCMFormatInt16) {
            NSLog(@"lingting error commonFormat is not AVAudioPCMFormatInt16");
            musicInfoCallback(errorDic);
            return;
        }
    } 
    

    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
        ACRCloudConfig *config = [[ACRCloudConfig alloc] init];

        config.accessKey = key;
        config.accessSecret = secret;
        config.host = @"identify-cn-north-1.acrcloud.com";
        config.protocol = @"https";

        //if you want to identify your offline db, set the recMode to "rec_mode_local"
        config.recMode = rec_mode_remote;
        config.requestTimeout = 10;
        config.recDataType = rec_data_audio;
        
        ACRCloudRecognition *client = [[ACRCloudRecognition alloc] initWithConfig:config];
        NSString* resultString = [client recognize:audiData];

        NSDictionary *adInfo = [NSJSONSerialization JSONObjectWithData:[resultString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        
        
    //    NSDictionary* statusDic = [adInfo objectForKey:@"status"];
    //    int statusCode = [[statusDic objectForKey:@"code"] intValue];
        musicInfoCallback(adInfo);

    });
    
    
}

@end
