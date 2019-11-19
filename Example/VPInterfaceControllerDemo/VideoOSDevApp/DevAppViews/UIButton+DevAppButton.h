//
//  UIButton+DevAppButton.h
//  VPInterfaceControllerDemo
//
//  Created by videopls on 2019/10/11.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (DevAppButton)

-(void)setGradientLayerForNormal;
-(void)setGradientLayerForCustomWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint colors:(NSArray*)colors;
@end

NS_ASSUME_NONNULL_END
