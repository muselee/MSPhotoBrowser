//
//  MSTransitionsManager.h
//  MSPhotoBrowser
//
//  Created by liqian on 15/11/29.
//  Copyright © 2015年 Bestdo. All rights reserved.
//
/*
 苹果支持的转场方式:
 Navigation controller 推入和推出页面(push-pop)
 Tab bar controller 选择的改变
 Modal 页面的展示和消失(present-dismiss)
 */
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


#define kMSTransitionActionCount        5

typedef NS_ENUM (NSInteger, MSTransitionAction) {
    MSTransitionAction_Push             = (1 << 0),
    MSTransitionAction_Pop              = (1 << 1),
    MSTransitionAction_Present          = (1 << 2),
    MSTransitionAction_Dismiss          = (1 << 3),
    MSTransitionAction_Tab              = (1 << 4),
    MSTransitionAction_PushPop          = MSTransitionAction_Push|MSTransitionAction_Pop,
    MSTransitionAction_PresentDismiss   = MSTransitionAction_Present|MSTransitionAction_Dismiss,
    MSTransitionAction_Any              = MSTransitionAction_Present|MSTransitionAction_Dismiss|MSTransitionAction_Tab,
};
@class MSTransitionsData;
//动画控制器 协议
@protocol MSAnimationControllerProtocol <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPositiveAnimation;

@end
//交互控制器 协议

@protocol MSTransitionInteractionControllerProtocol <UIViewControllerInteractiveTransitioning>

@property (assign, nonatomic, readwrite) BOOL isInteractive;

@property (assign ,nonatomic, readwrite) BOOL shouldCompleteTransition;

@property (assign, nonatomic, readwrite) MSTransitionAction action;

- (void)attachViewController:(UIViewController *)viewController withAction:(MSTransitionAction)action;
@end



@interface MSTransitionsData : NSObject<NSCopying>


@property (assign, nonatomic) MSTransitionAction transitionAction;
@property (assign, nonatomic) Class fromViewControllerClass;
@property (assign, nonatomic) Class toViewControllerClass;

//初始化
- (instancetype)initWithAction:(MSTransitionAction)action withFromViewControllerClass:(Class)fromViewController
     withToViewControllerClass:(Class)toViewController;

@end

/*
 Navigationcontroller 推入和推出页面(push-pop),Tabbarcontroller 选择的改变,Modal 页面的展示和消失(present-dismiss) 转场代理类
 */

@interface MSControllerTransitioningDelegate : NSObject<UINavigationControllerDelegate,UIViewControllerTransitioningDelegate,UITabBarControllerDelegate>

@property (strong, nonatomic) id<MSAnimationControllerProtocol> defaultPushPopAnimationController;

@property (strong, nonatomic) id<MSAnimationControllerProtocol>  defaultPresentDismissAnimationController;

@property (strong, nonatomic) id<MSAnimationControllerProtocol>  defaultTabBarAnimationController;


+ (instancetype)shareInstance;

//初始化动画转场
- (void )animationController:(id<MSAnimationControllerProtocol>)animationController
                                   fromViewController:(Class )fromViewController
                                            forAction:(MSTransitionAction)action;


- (void )animationController:(id<MSAnimationControllerProtocol>)animationController
                                    fromViewController:(Class)fromViewController
                                      toViewController:(Class)toViewController
                                             forAction:(MSTransitionAction)action;


//初始化交互转场
- (void )interactionController:(id<MSTransitionInteractionControllerProtocol>)interactionController
                                      fromViewController:(Class)fromViewController
                                        toViewController:(Class)toViewController
                                               forAction:(MSTransitionAction)action;


- (void)overrideAnimationDirection:(BOOL)isOverride withTransition:(MSTransitionsData *)transitionKey;

@end

@interface NSObject(MSTransitions)

- (UIView *)toView;

- (UIView *)fromView;
@end
