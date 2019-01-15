//
//  VPUPCipherOperation.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPCipherOperation : NSObject

+ (NSData *)vpup_cipherOperationWithContent:(NSData *)contentData
                                        key:(NSData *)keyData
                                 initVector:(NSData *)initVectorData
                                  operation:(uint32_t)operation
                                  algorithm:(uint32_t)algorithm
                                    options:(uint32_t)options
                                    keySize:(size_t)keySize
                                  blockSize:(size_t)blockSize;

+ (NSData *)vpup_aesCipherOperationWithContent:(NSData *)contentData
                                           key:(NSData *)keyData
                                    initVector:(NSData *)initVectorData
                                     operation:(uint32_t)operation;

+ (NSData *)vpup_aesEncryptWithContent:(NSData *)contentData
                                   key:(NSData *)keyData
                            initVector:(NSData *)initVectorData;

+ (NSData *)vpup_aesDecryptWithContent:(NSData *)contentData
                                   key:(NSData *)keyData
                            initVector:(NSData *)initVectorData;

@end
