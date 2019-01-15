//
//  VPUPResizeControl.h
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol VPUPResizeControlDelegate;

@interface VPUPResizeControl : UIView

@property (nonatomic, weak) id<VPUPResizeControlDelegate> delegate;
@property (nonatomic, readonly) CGPoint translation;

@end

@protocol VPUPResizeControlDelegate <NSObject>

- (void)vpup_resizeConrolDidBeginResizing:(VPUPResizeControl *)resizeConrol;
- (void)vpup_resizeConrolDidResizing:(VPUPResizeControl *)resizeConrol;
- (void)vpup_resizeConrolDidEndResizing:(VPUPResizeControl *)resizeConrol;

@end
