//
//  VPLuaLoadingView.m
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/9/6.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLuaLoadingView.h"
#import <UIKit/UIKit.h>


@interface VPLuaLoadingView()

@property (nonatomic, strong) UIActivityIndicatorView* loading;

@end

@implementation VPLuaLoadingView


- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        self.loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.loading.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.loading sizeToFit];
        [self.loading startAnimating];
        [self addSubview:self.loading];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if( self.loading ) {
        self.loading.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height * 0.48);
    }
}

- (id)lv_nativeObject {
    return self.loading;
}

@end
