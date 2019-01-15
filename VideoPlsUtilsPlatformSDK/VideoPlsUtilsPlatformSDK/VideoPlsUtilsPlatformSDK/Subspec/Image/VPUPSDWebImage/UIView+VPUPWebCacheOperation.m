/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#import "UIView+VPUPWebCacheOperation.h"
#import "VPUPSDWebImageOperation.h"

#if VPUPSD_UIKIT || VPUPSD_MAC

#import "objc/runtime.h"

static char loadOperationKey;

typedef NSMutableDictionary<NSString *, id> VPUPSDOperationsDictionary;

@implementation UIView (VPUPWebCacheOperation)

- (VPUPSDOperationsDictionary *)operationDictionary {
    VPUPSDOperationsDictionary *operations = objc_getAssociatedObject(self, &loadOperationKey);
    if (operations) {
        return operations;
    }
    operations = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return operations;
}

- (void)vpupsd_setImageLoadOperation:(nullable id)operation forKey:(nullable NSString *)key {
    if (key) {
        [self vpupsd_cancelImageLoadOperationWithKey:key];
        if (operation) {
            VPUPSDOperationsDictionary *operationDictionary = [self operationDictionary];
            operationDictionary[key] = operation;
        }
    }
}

- (void)vpupsd_cancelImageLoadOperationWithKey:(nullable NSString *)key {
    // Cancel in progress downloader from queue
    VPUPSDOperationsDictionary *operationDictionary = [self operationDictionary];
    id operations = operationDictionary[key];
    if (operations) {
        if ([operations isKindOfClass:[NSArray class]]) {
            for (id <VPUPSDWebImageOperation> operation in operations) {
                if (operation) {
                    [operation cancel];
                }
            }
        } else if ([operations conformsToProtocol:@protocol(VPUPSDWebImageOperation)]){
            [(id<VPUPSDWebImageOperation>) operations cancel];
        }
        [operationDictionary removeObjectForKey:key];
    }
}

- (void)vpupsd_removeImageLoadOperationWithKey:(nullable NSString *)key {
    if (key) {
        VPUPSDOperationsDictionary *operationDictionary = [self operationDictionary];
        [operationDictionary removeObjectForKey:key];
    }
}

@end

#endif

#endif
