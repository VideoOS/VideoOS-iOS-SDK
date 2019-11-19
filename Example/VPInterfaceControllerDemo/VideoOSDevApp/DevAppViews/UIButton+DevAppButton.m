//
//  UIButton+DevAppButton.m
//  VPInterfaceControllerDemo
//
//  Created by videopls on 2019/10/11.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "UIButton+DevAppButton.h"

@implementation UIButton (DevAppButton)
-(void)setGradientLayerForNormal{
    self.backgroundColor = [UIColor clearColor];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = @[(id)[UIColor colorWithRed:47/255.0 green:228/255.0 blue:173/255.0 alpha:1.0].CGColor , (id)[UIColor colorWithRed:31/255.0 green:187/255.0 blue:120/255.0 alpha:1.0].CGColor];
    gradient.startPoint = CGPointMake(0, 1);
    gradient.endPoint = CGPointMake(1, 1);
    gradient.cornerRadius = gradient.frame.size.height / 2.0;
    [self.layer insertSublayer:gradient atIndex:0];
}

-(void)setGradientLayerForCustomWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint colors:(NSArray*)colors{
    
}
@end
