//
//  MSCircleAnimationController.h
//  MSPhotoBrowser
//
//  Created by liqian on 15/11/30.
//  Copyright © 2015年 Bestdo. All rights reserved.
//

#import "MSZoomAlphaAnimationController.h"


@protocol MSCircleAnimationControllerDelegate <NSObject>

@optional

- (CGPoint)circleCenter;

- (CGFloat)circleStartingRadius;
@end

@interface MSCircleAnimationController : MSZoomAlphaAnimationController

@property (weak, nonatomic) id<MSCircleAnimationControllerDelegate> circleDelegate;

@property (assign, nonatomic) CGFloat maximumCircleScale;

@property (assign, nonatomic) CGFloat minimumCircleScale;
@end
