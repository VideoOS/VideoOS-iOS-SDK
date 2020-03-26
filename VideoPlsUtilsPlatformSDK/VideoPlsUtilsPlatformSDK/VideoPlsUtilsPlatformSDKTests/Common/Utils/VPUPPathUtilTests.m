//
//  VPUPPathUtilTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/26.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPPathUtil.h"

@interface VPUPPathUtilTests : XCTestCase

@end

@implementation VPUPPathUtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPath {
    NSString *path = [VPUPPathUtil path];
    NSString *path2 = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    path2 = [path2 stringByAppendingPathComponent:@"videopls"];
    
    XCTAssertTrue([path isEqualToString:path2], @"Get path equal");
    BOOL isDir = false;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
}

- (void)testPathByPlaceholder {
    NSString *luaPath = [VPUPPathUtil pathByPlaceholder:@"lua"];
    
    NSString *luaPath2 = [VPUPPathUtil path];
    luaPath2 = [luaPath2 stringByAppendingPathComponent:@"lua"];
    
    XCTAssertTrue([luaPath isEqualToString:luaPath2], @"Get path equal");
    BOOL isDir = false;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:luaPath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
}

- (void)testSubPath {
    BOOL isDir = false;
    
    NSString *reportPath = [VPUPPathUtil reportPath];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:reportPath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
    
    NSString *cytronPath = [VPUPPathUtil cytronPath];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:cytronPath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
    
    NSString *livePath = [VPUPPathUtil livePath];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:livePath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
    
    NSString *imagePath = [VPUPPathUtil imagePath];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
    
    NSString *videoModePath = [VPUPPathUtil videoModePath];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:videoModePath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
    
    NSString *lPath = [VPUPPathUtil lPath];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:lPath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
    
    NSString *lOSPath = [VPUPPathUtil lOSPath];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:lOSPath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
    
    NSString *lmpPath = [VPUPPathUtil lmpPath];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:lmpPath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
    
    NSString *appDevPath = [VPUPPathUtil appDevPath];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:appDevPath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
    
    // only copy for app dev, file didn't exist
    NSString *appDevConfigPath = [VPUPPathUtil appDevConfigPath];
    XCTAssertNotNil(appDevConfigPath, @"Path is not nil");
    
    NSString *goodsPath = [VPUPPathUtil goodsPath];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:goodsPath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
    
    NSString *localStoragePath = [VPUPPathUtil localStoragePath];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:localStoragePath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
}

- (void)testSubPathOfPath {
    BOOL isDir = false;
    
    NSString *subLOSPath = [VPUPPathUtil subPathOfLOSPath:@"testPath"];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:subLOSPath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
    NSString *losPath = [VPUPPathUtil lOSPath];
    losPath = [losPath stringByAppendingPathComponent:@"testPath"];
    XCTAssertTrue([subLOSPath isEqualToString:losPath], @"Get path equal");
    
    [[NSFileManager defaultManager] removeItemAtPath:subLOSPath error:nil];
    
    
    NSString *subLPath = [VPUPPathUtil subPathOfLua:@"testPath"];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:subLPath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
    NSString *lPath = [VPUPPathUtil lPath];
    lPath = [lPath stringByAppendingPathComponent:@"testPath"];
    XCTAssertTrue([subLPath isEqualToString:lPath], @"Get path equal");
    
    [[NSFileManager defaultManager] removeItemAtPath:subLPath error:nil];
    
    
    NSString *subLMPPath = [VPUPPathUtil subPathOfLMP:@"testPath"];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:subLMPPath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
    NSString *lmpPath = [VPUPPathUtil lmpPath];
    lmpPath = [lmpPath stringByAppendingPathComponent:@"testPath"];
    XCTAssertTrue([subLPath isEqualToString:lPath], @"Get path equal");
    
    [[NSFileManager defaultManager] removeItemAtPath:subLMPPath error:nil];
    
    
    NSString *subVideoModePath = [VPUPPathUtil subPathOfVideoMode:@"testPath"];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:subVideoModePath isDirectory:&isDir], @"Path is exsist");
    XCTAssertTrue(isDir, @"Path is directory");
    NSString *videoModePath = [VPUPPathUtil videoModePath];
    videoModePath = [videoModePath stringByAppendingPathComponent:@"testPath"];
    XCTAssertTrue([subVideoModePath isEqualToString:videoModePath], @"Get path equal");
    
    [[NSFileManager defaultManager] removeItemAtPath:subVideoModePath error:nil];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
