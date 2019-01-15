//
//  VPLoginViewController.h
//  VPInterfaceControllerDemo
//
//  Created by peter on 2018/11/12.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^loginComplete)(void);

@interface VPLoginViewController : UIViewController

@property (nonatomic, copy) loginComplete complete;

@end

NS_ASSUME_NONNULL_END
