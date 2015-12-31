//
//  MSCircleAnimationController.m
//  MSPhotoBrowser
//
//  Created by liqian on 15/11/30.
//  Copyright © 2015年 Bestdo. All rights reserved.
//

#import "MSCircleAnimationController.h"

#define kCircleDefaultMaxScale    2.5f
#define kCircleDefaultMinScale    0.25f
#define kCircleAnimationTime      0.5f
#define kCircleMaskAnimation      @"kCircleMaskAnimation"
@implementation MSCircleAnimationController
@synthesize isPositiveAnimation = _isPositiveAnimation;

- (instancetype)init{
    self = [super init];
    if ( self ) {
        _minimumCircleScale = kCircleDefaultMinScale;
        _maximumCircleScale = kCircleDefaultMaxScale;
    }
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIView *fromView = [(NSObject *)transitionContext fromView];
    UIView *toView = [(NSObject *)transitionContext toView];
    
    CGRect bounds = fromView.bounds;
    CAShapeLayer *circleMaskLayer = [CAShapeLayer layer];
    circleMaskLayer.frame = bounds;
    
    // Calculate the size the circle should start at
    CGFloat radius = [self circleStartingRadiusWithFromView:fromView toView:toView];
    
    // Calculate the center point of the circle
    CGPoint circleCenter = [self circleCenterPointWithFromView:fromView];
    circleMaskLayer.position = circleCenter;
    CGRect circleBoundingRect = CGRectMake(circleCenter.x - radius, circleCenter.y - radius, 2.0*radius, 2.0*radius);
    circleMaskLayer.path = [UIBezierPath bezierPathWithOvalInRect:circleBoundingRect].CGPath;
    circleMaskLayer.bounds = circleBoundingRect;
    
    CABasicAnimation *circleMaskAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    circleMaskAnimation.duration            = kCircleAnimationTime;
    circleMaskAnimation.repeatCount         = 1.0;    // Animate only once
    circleMaskAnimation.removedOnCompletion = NO;     // Remain after the animation
    
    // Set manual easing on the animation.  Tweak for fun!
    [circleMaskAnimation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.34 :.01 :.69 :1.37]];
    
    if ( self.isPositiveAnimation ) {
        [circleMaskAnimation setFillMode:kCAFillModeForwards];
        
        // Animate from small to large
        circleMaskAnimation.fromValue = @(self.minimumCircleScale);
        circleMaskAnimation.toValue   = @(self.maximumCircleScale);
        
        // Add to the view and start the animation
        toView.layer.mask = circleMaskLayer;
        toView.layer.masksToBounds = YES;
        [circleMaskLayer addAnimation:circleMaskAnimation forKey:kCircleMaskAnimation];
    }
    else {
        [circleMaskAnimation setFillMode:kCAFillModeForwards];
        
        // Animate from large to small
        circleMaskAnimation.fromValue = @(1.0f);
        circleMaskAnimation.toValue   = @(self.minimumCircleScale);
        
        // Add to the view and start the animation
        fromView.layer.mask = circleMaskLayer;
        fromView.layer.masksToBounds = YES;
        [circleMaskLayer addAnimation:circleMaskAnimation forKey:kCircleMaskAnimation];
    }
    
    [super animateTransition:transitionContext];
}

#pragma mark - Helper Methods

// Calculate the center point of the circle
- (CGPoint)circleCenterPointWithFromView:(UIView *)fromView
{
    CGPoint center = CGPointZero;
    if ( self.circleDelegate && [self.circleDelegate respondsToSelector:@selector(circleCenter)] ) {
        center = [self.circleDelegate circleCenter];
    }
    else {
        center = CGPointMake(fromView.bounds.origin.x + fromView.bounds.size.width / 2,
                             fromView.bounds.origin.y + fromView.bounds.size.height / 2);
    }
    return center;
}

// Calculate the size the circle should start at
- (CGFloat)circleStartingRadiusWithFromView:(UIView *)fromView toView:(UIView *)toView
{
    CGFloat radius = 0.0f;
    if ( self.circleDelegate && [self.circleDelegate respondsToSelector:@selector(circleStartingRadius)] ) {
        radius = [self.circleDelegate circleStartingRadius];
        CGRect bounds = toView.bounds;
        self.maximumCircleScale = ((MAX(bounds.size.height, bounds.size.width) / (radius)) * 1.25);
    }
    else {
        CGRect bounds = fromView.bounds;
        CGFloat diameter = MIN(bounds.size.height, bounds.size.width);
        radius = diameter / 2;
    }
    return radius;
}

@end
