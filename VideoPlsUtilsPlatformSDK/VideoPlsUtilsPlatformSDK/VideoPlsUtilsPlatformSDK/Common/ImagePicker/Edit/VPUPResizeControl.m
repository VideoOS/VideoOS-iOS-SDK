//
//  VPUPResizeControl.m
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPUPResizeControl.h"

@interface VPUPResizeControl ()

@property (nonatomic, readwrite) CGPoint translation;
@property (nonatomic, assign) CGPoint startPoint;

@end

@implementation VPUPResizeControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
    
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint translationInView = [gestureRecognizer translationInView:self.superview];
        self.startPoint = CGPointMake(roundf(translationInView.x), translationInView.y);
        
        if ([self.delegate respondsToSelector:@selector(vpup_resizeConrolDidBeginResizing:)]) {
            [self.delegate vpup_resizeConrolDidBeginResizing:self];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self.superview];
        self.translation = CGPointMake(roundf(self.startPoint.x + translation.x),
                                       roundf(self.startPoint.y + translation.y));
        
        if ([self.delegate respondsToSelector:@selector(vpup_resizeConrolDidResizing:)]) {
            [self.delegate vpup_resizeConrolDidResizing:self];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        if ([self.delegate respondsToSelector:@selector(vpup_resizeConrolDidEndResizing:)]) {
            [self.delegate vpup_resizeConrolDidEndResizing:self];
        }
    }
}

@end
