//
//  NSURL+VPUPPlayer.m
//  ResourceLoader
//
//  Created by peter on 2018/5/4.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "NSURL+VPUPPlayer.h"
#import "objc/runtime.h"

@implementation NSURL (VPUPPlayer)

- (NSURL *)vpup_customSchemeURL {
    NSURLComponents * components = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}

- (NSURL *)vpup_originalSchemeURL {
    NSURLComponents * components = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = @"http";
    return [components URL];
}

@end
