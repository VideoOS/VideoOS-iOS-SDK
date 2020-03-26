//
//  ACRCloud_IOS_SDK.h
//  ACRCloud_IOS_SDK
//
//  Created by olym on 15/3/24.
//  Copyright (c) 2015年 ACRCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACRCloudConfig.h"

@interface ACRCloudRecognition : NSObject

-(id)initWithConfig:(ACRCloudConfig*)config;

-(void)startPreRecord:(NSInteger)recordTime;
-(void)stopPreRecord;

-(void)startRecordRec;

-(void)stopRecordRec;

-(void)stopRecordAndRec;

//only support RIFF (little-endian) data, WAVE audio, Microsoft PCM, 16 bit, mono 8000 Hz
-(NSString*)recognize:(char*)buffer len:(int)len;

//only support RIFF (little-endian) data, WAVE audio, Microsoft PCM, 16 bit, mono 8000 Hz
-(NSString*)recognize:(NSData*)pcm_data;

-(void)recognize_fp:(NSData*)fingerprint
        resultBlock:(ACRCloudResultBlock)resultBlock;

-(NSString*)recognize_fp:(NSData*)fingerprint;
-(NSString*)recognize_hum_fp:(NSData*)fingerprint;

//only support RIFF (little-endian) data, WAVE audio, Microsoft PCM, 16 bit, mono 8000 Hz
+(NSData*)get_fingerprint:(char*)pcm len:(int)len;
+(NSData*)get_fingerprint:(NSData*)pcm;
+(NSData*)get_hum_fingerprint:(NSData*)pcm;

+(NSData*) get_fingerprint:(char*)pcm
                     len:(unsigned)len
                sampleRate:(unsigned)sampleRate
                  nChannel:(short)nChannel;
+(NSData*)get_fingerprint:(NSData*)pcm
               sampleRate:(unsigned)sampleRate
                 nChannel:(short)nChannel;

//convert pcm/wav to mono 8000HZ
+(NSData*) resample:(NSData*)pcm
         sampleRate:(unsigned)sampleRate
           nChannel:(short)nChannel;

+(NSData*) resample:(char*)pcm
                len:(unsigned)len
         sampleRate:(unsigned)sampleRate
           nChannel:(short)nChannel;

+(NSData*) resample_bit32:(char*)pcm
                      len:(unsigned)bytes
               sampleRate:(unsigned)sampleRate
                 nChannel:(short)nChannel
                  isFloat:(bool)isFloat;

+(NSString*) version;
@end
