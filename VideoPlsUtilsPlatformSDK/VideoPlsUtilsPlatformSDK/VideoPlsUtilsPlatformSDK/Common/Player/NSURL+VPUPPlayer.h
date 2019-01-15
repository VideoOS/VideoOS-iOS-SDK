//
//  NSURL+VPUPPlayer.h
//  ResourceLoader
//
//  Created by peter on 2018/5/4.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (VPUPPlayer)

/**
 *  自定义scheme
 */
- (NSURL *)vpup_customSchemeURL;

/**
 *  还原scheme
 */
- (NSURL *)vpup_originalSchemeURL;

@end
