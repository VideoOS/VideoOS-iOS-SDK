//
//  VPLNormalRefreshHeader.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096 on 2017/12/19.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLNormalRefreshHeader.h"
#import <UIKit/UIKit.h>

@interface VPLNormalRefreshHeader()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation VPLNormalRefreshHeader

- (void)prepare {
    [super prepare];
    {
        CGRect frame = self.frame;
        frame.size.height = 40;
        self.frame = frame;
        
        if(!self.indicatorView) {
            self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.indicatorView.hidesWhenStopped = NO;
            [self addSubview:self.indicatorView];
//            self.indicatorView.center = self.center;
        }
        
    }
}

- (void)placeSubviews {
//    self.indicatorView.center = self.center;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
//    self.indicatorView.transform = CGAffineTransformIdentity;
    CGRect frame = self.indicatorView.frame;
    frame.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(frame)) / 2;
    frame.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(frame)) / 2;
    self.indicatorView.frame = frame;
    
    [CATransaction commit];
    
    [super placeSubviews];
}


//- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
//    [super scrollViewContentOffsetDidChange:change];
//
//    if(![change objectForKey:@"new"]) {
//        return;
//    }
//    CGPoint changeValue = [[change objectForKey:@"new"] CGPointValue];
//    if (changeValue.y < 0) {
//        self.indicatorView.transform = CGAffineTransformMakeRotation(changeValue.y / 20 * M_PI_2);
//    }
//    else {
//        self.indicatorView.transform = CGAffineTransformIdentity;
//    }
//
//
//}

- (void)beginRefreshing {
    [super beginRefreshing];
    [self.indicatorView startAnimating];
}

- (void)endRefreshing {
    [super endRefreshing];
    [self.indicatorView stopAnimating];
}

@end
