//
//  NSURL+VPUPPlayer.m
//  ResourceLoader
//
//  Created by peter on 2018/5/4.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "NSURL+VPUPPlayer.h"
#import "objc/runtime.h"

@interface NSURL()

@property (nonatomic) NSString *vpup_originalScheme;

@end

@implementation NSURL (VPUPPlayer)

- (NSURL *)vpup_customSchemeURL {
    NSURLComponents * components = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    self.vpup_originalScheme = components.scheme;
    components.scheme = @"streaming";
    return [components URL];
}

- (NSURL *)vpup_originalSchemeURL {
    NSURLComponents * components = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    if (self.vpup_originalScheme) {
        components.scheme = self.vpup_originalScheme;
    } else {
        components.scheme = @"http";
    }
    return [components URL];
}

- (NSString *)vpup_originalScheme {
    NSString *originalScheme = nil;
    NSString *value = objc_getAssociatedObject(self, @selector(vpup_originalScheme));
    if ([value isKindOfClass:[NSString class]]) {
        originalScheme = value;
    }
    return originalScheme;
}

- (void)setVpup_originalScheme:(NSString *)originalScheme {
    if (!originalScheme) {
        return;
    }
    objc_setAssociatedObject(self, @selector(vpup_originalScheme), originalScheme, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
