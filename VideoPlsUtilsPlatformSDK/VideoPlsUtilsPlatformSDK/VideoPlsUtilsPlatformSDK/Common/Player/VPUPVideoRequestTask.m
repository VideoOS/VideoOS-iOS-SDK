//
//  VPUPVideoRequestTask.m
//  ResourceLoader
//
//  Created by peter on 2018/5/4.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPVideoRequestTask.h"
#import "VPUPFileHandle.h"
#import "NSURL+VPUPPlayer.h"

@interface VPUPVideoRequestTask () <NSURLConnectionDataDelegate, AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableArray *taskArr;
@property (nonatomic, assign) NSUInteger cacheLength;
@property (nonatomic, assign) BOOL once;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSString *tempFilePath;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation VPUPVideoRequestTask

- (instancetype)init {
    self = [super init];
    if (self) {
    
    }
    return self;
}

- (NSString *)tempFilePath {
    if (!_tempFilePath) {
        _tempFilePath = [VPUPFileHandle tempFilePathWithURL:[self.url vpup_originalSchemeURL]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_tempFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:_tempFilePath error:nil];
        }
        [[NSFileManager defaultManager] createFileAtPath:_tempFilePath contents:nil attributes:nil];
    }
    return _tempFilePath;
}

- (NSString *)filePath {
    if (!_filePath) {
        _filePath = [VPUPFileHandle filePathWithURL:[self.url vpup_originalSchemeURL]];
    }
    return _filePath;
}

- (void)start {
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[self.url vpup_originalSchemeURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:RequestTimeout];
    if (self.offset > 0) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld", self.offset, self.fileLength - 1] forHTTPHeaderField:@"Range"];
    }
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self.dataTask resume];
}

- (void)cancel
{
    [self.dataTask cancel];
    [self.session invalidateAndCancel];
}


#pragma mark -  NSURLConnection Delegate Methods

////网络中断：-1005
////无网络连接：-1009
////请求超时：-1001
////服务器内部错误：-1004
////找不到服务器：-1003
//{
//    if (error.code == -1001 && !_once) {      //网络超时，重连一次
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self continueLoading];
//        });
//    }
////    if ([self.delegate respondsToSelector:@selector(didFailLoadingWithTask:WithError:)]) {
////        [self.delegate didFailLoadingWithTask:self WithError:error.code];
////    }
//    if (error.code == -1009) {
//        NSLog(@"无网络连接");
//    }
//}


- (void)continueLoading
{
    _once = YES;
    NSURLComponents *actualURLComponents = [[NSURLComponents alloc] initWithURL:_url resolvingAgainstBaseURL:NO];
    actualURLComponents.scheme = @"http";

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[actualURLComponents URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];

    if (_cacheLength > 0 && self.fileLength > 1) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld",(unsigned long)_cacheLength, (unsigned long)self.fileLength - 1] forHTTPHeaderField:@"Range"];
    }
    
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self.dataTask resume];
}

- (void)clearData
{
    [self.dataTask cancel];
    [self.session invalidateAndCancel];
    //移除文件
    [[NSFileManager defaultManager] removeItemAtPath:_tempFilePath error:nil];
}

#pragma mark - NSURLSessionDataDelegate
//服务器响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    NSLog(@"response: %@",response);
    completionHandler(NSURLSessionResponseAllow);
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    NSString * contentLength = [[httpResponse allHeaderFields] objectForKey:@"Content-Length"];
    NSString * fileLength = contentLength;
    self.fileLength = fileLength.integerValue > 0 ? fileLength.integerValue : response.expectedContentLength;
    self.mimeType = [[httpResponse allHeaderFields] objectForKey:@"Content-Type"];
}

//服务器返回数据 可能会调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [VPUPFileHandle writeToFile:self.tempFilePath data:data];
    self.cacheLength += data.length;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveVideoDataWithTask:)]) {
        [self.delegate didReceiveVideoDataWithTask:self];
    }
}

//请求完成会调用该方法，请求失败则error有值
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error) {
        if (error && error.code == -1001 && !_once) {      //网络超时，重连一次
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self continueLoading];
            });
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didFailLoadingWithTask:error:)]) {
                [self.delegate didFailLoadingWithTask:self error:error];
            }
        }
    }
    else {
        //可以缓存则保存文件
        if (self.cacheFile) {
            [[NSFileManager defaultManager] moveItemAtPath:self.tempFilePath toPath:self.filePath error:nil];
            [VPUPFileHandle saveOrUpdateCacheFile:self.filePath];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishLoadingWithTask:)]) {
            [self.delegate didFinishLoadingWithTask:self];
        }
    }
}

@end
