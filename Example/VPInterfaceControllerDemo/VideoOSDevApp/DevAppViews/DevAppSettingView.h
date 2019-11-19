//
//  DevAppSettingView.h
//  VPInterfaceControllerDemo
//
//  Created by videopls on 2019/10/10.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol DevAppSettingViewDelegate <NSObject>

-(void)settingViewDidCompleWithData:(NSArray<NSString*>*)data andIsOK:(BOOL)isOK andISLocaleModle:(BOOL)isLocal;

@end


@interface DevAppSettingView : UIView
@property (nonatomic, weak) id<DevAppSettingViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame controllerType:(DebuggingControllerType)type;

-(void)fadeInAnimation;
-(void)fadeOutAnimationWithOK:(BOOL)isOK;

@end

NS_ASSUME_NONNULL_END
