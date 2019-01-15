//
//  VPUPCipherOperation.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPCipherOperation.h"
#import "VPUPValidator.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation VPUPCipherOperation

+ (NSData *)vpup_cipherOperationWithContent:(NSData *)contentData
                                        key:(NSData *)keyData
                                 initVector:(NSData *)initVectorData
                                  operation:(CCOperation)operation
                                  algorithm:(CCAlgorithm)algorithm
                                    options:(CCOptions)options
                                    keySize:(size_t)keySize
                                  blockSize:(size_t)blockSize {
    
    if(!VPUP_IsExist(contentData) || !VPUP_IsExist(keyData)) {
        return nil;
    }
    
    NSUInteger dataLength = contentData.length;
    
    void const *initVectorBytes = initVectorData.bytes;
    void const *contentBytes = contentData.bytes;
    void const *keyBytes = keyData.bytes;
    
    size_t operationSize = dataLength + blockSize;
    void *operationBytes = malloc(operationSize);
    size_t dataOutMoved = 0;
    
    CCCryptorStatus status = CCCrypt(operation,
                                     algorithm,
                                     options,
                                     keyBytes,
                                     keySize,
                                     initVectorBytes,
                                     contentBytes,
                                     dataLength,
                                     operationBytes,
                                     operationSize,
                                     &dataOutMoved);
    
//    CCCryptorRef cryptor = NULL;
//    CCCryptorStatus status = CCCryptorCreate(operation, algorithm, options, keyBytes, keySize, initVectorBytes, &cryptor);
//    
//    NSMutableData *retData = [NSMutableData new];
//    
//    // 2. Encrypt or decrypt data.
////    NSMutableData *buffer = [NSMutableData data];
////    [buffer setLength:CCCryptorGetOutputLength(cryptor, dataLength, true)]; // We'll reuse the buffer in -finish
//    
//    size_t dataOutMoved;
//    status = CCCryptorUpdate(cryptor, contentBytes, dataLength, operationBytes, operationSize, &dataOutMoved);
//    NSAssert(status == kCCSuccess, @"Failed to encrypt or decrypt data");
//    [retData appendData:[[NSData dataWithBytes:operationBytes length:operationSize] subdataWithRange:NSMakeRange(0, dataOutMoved)]];
//    
//    // 3. Finish the encrypt or decrypt operation.
//    status = CCCryptorFinal(cryptor, operationBytes, operationSize, &dataOutMoved);
    
    NSData *resultData = nil;
    if (status == kCCSuccess) {
        resultData = [NSData dataWithBytes:operationBytes length:dataOutMoved];
    }
    
    free(operationBytes);
    
    return resultData;
}

+ (NSData *)vpup_aesCipherOperationWithContent:(NSData *)contentData
                                           key:(NSData *)keyData
                                    initVector:(NSData *)initVectorData
                                     operation:(CCOperation)operation {
    
    //    kCCKeySizeAES128          = 16,
    //    kCCKeySizeAES192          = 24,
    //    kCCKeySizeAES256          = 32,
    
    if(!VPUP_IsExist(contentData) || !VPUP_IsExist(keyData) || !VPUP_IsExist(initVectorData)) {
        return nil;
    }
    NSAssert(keyData.length == kCCKeySizeAES128 || keyData.length == kCCKeySizeAES192 || keyData.length == kCCKeySizeAES256, @"AES must have a key size of 128, 192, or 256 bits.");
    NSAssert1(initVectorData.length == kCCBlockSizeAES128, @"AES must have a fixed IV size of %d-bytes regardless key size.", kCCBlockSizeAES128);
    
    size_t keySize = keyData.length;
    return [self vpup_cipherOperationWithContent:contentData
                                             key:keyData
                                      initVector:initVectorData
                                       operation:operation
                                       algorithm:kCCAlgorithmAES
                                         options:kCCOptionPKCS7Padding                      //default is cbc
                                         keySize:keySize
                                       blockSize:kCCBlockSizeAES128];
}

+ (NSData *)vpup_aesEncryptWithContent:(NSData *)contentData
                                   key:(NSData *)keyData
                            initVector:(NSData *)initVectorData {
    
    return [self vpup_aesCipherOperationWithContent:contentData
                                                key:keyData
                                         initVector:initVectorData
                                          operation:kCCEncrypt];
}

+ (NSData *)vpup_aesDecryptWithContent:(NSData *)contentData
                                   key:(NSData *)keyData
                            initVector:(NSData *)initVectorData {
    
    return [self vpup_aesCipherOperationWithContent:contentData
                                                key:keyData
                                         initVector:initVectorData
                                          operation:kCCDecrypt];
}

@end
