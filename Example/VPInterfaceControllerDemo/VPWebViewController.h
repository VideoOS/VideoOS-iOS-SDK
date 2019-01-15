//
//  VPWebViewController.h
//  VPInterfaceControllerDemo
//
//  Created by peter on 2018/9/13.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VPWebViewController : UIViewController

- (void)loadUrl:(NSString *)url close:(void(^)(void))closeHandle;

@end
