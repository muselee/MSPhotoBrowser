//
//  MSZoomAlphaAnimationController.m
//  MSPhotoBrowser
//
//  Created by liqian on 15/11/30.
//  Copyright © 2015年 Bestdo. All rights reserved.
//

#import "MSZoomAlphaAnimationController.h"

#define kMSPushTransitionTime 0.35
#define kMSPushScaleChangePct 0.33

@implementation MSZoomAlphaAnimationController
@synthesize isPositiveAnimation = _isPositiveAnimation;


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIView *toView = [(NSObject *)transitionContext toView];
    UIView *fromView = [(NSObject *)transitionContext fromView];
    UIView *container = [transitionContext containerView];
    
    if ( self.isPositiveAnimation ) {
        toView.frame = container.frame;
        [container insertSubview:toView belowSubview:fromView];
        toView.transform = CGAffineTransformMakeScale(1.0 - kMSPushScaleChangePct, 1.0 - kMSPushScaleChangePct);
        
        [UIView animateWithDuration:kMSPushTransitionTime
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             toView.transform = CGAffineTransformIdentity;
                             fromView.transform = CGAffineTransformMakeScale(1.0 + kMSPushScaleChangePct, 1.0 + kMSPushScaleChangePct);
                             fromView.alpha = 0.0f;
                         }completion:^(BOOL finished) {
                             toView.transform = CGAffineTransformIdentity;
                             fromView.transform = CGAffineTransformIdentity;
                             fromView.alpha = 1.0f;
                             [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                         }];
    }else {
        if (transitionContext.presentationStyle == UIModalPresentationNone) {
            [container insertSubview:toView belowSubview:fromView];
        }
        toView.transform = CGAffineTransformMakeScale(1.0 + kMSPushScaleChangePct, 1.0 + kMSPushScaleChangePct);
        toView.alpha = 0.0f;
        
        [UIView animateWithDuration:kMSPushTransitionTime
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             toView.transform = CGAffineTransformIdentity;
                             toView.alpha = 1.0f;
                             fromView.alpha = 0.0f;
                             fromView.transform = CGAffineTransformMakeScale(1.0 - kMSPushScaleChangePct, 1.0 - kMSPushScaleChangePct);
                         }
                         completion:^(BOOL finished) {
                             toView.transform = CGAffineTransformIdentity;
                             fromView.transform = CGAffineTransformIdentity;
                             toView.alpha = 1.0f;
                             [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                         }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    return kMSPushTransitionTime;
}

@end
