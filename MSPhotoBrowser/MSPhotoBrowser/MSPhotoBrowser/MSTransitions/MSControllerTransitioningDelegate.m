//
//  MSTransitionsManager.m
//  MSPhotoBrowser
//
//  Created by liqian on 15/11/29.
//  Copyright © 2015年 Bestdo. All rights reserved.
//

#import "MSControllerTransitioningDelegate.h"

//转场数据组装类的实现
@implementation MSTransitionsData

- (instancetype)initWithAction:(MSTransitionAction)action
   withFromViewControllerClass:(Class)fromViewController
     withToViewControllerClass:(Class)toViewController{
    self = [super init];
    if ( self ) {
        _transitionAction = action;
        _fromViewControllerClass = fromViewController;
        _toViewControllerClass = toViewController;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone{
    
    MSTransitionsData *copiedObject = [[[self class] allocWithZone:zone] init];
    copiedObject.transitionAction = self.transitionAction;
    copiedObject.toViewControllerClass = self.toViewControllerClass;
    copiedObject.fromViewControllerClass = self.fromViewControllerClass;
    
    return copiedObject;
}

- (NSUInteger)hash{
    return [[self fromViewControllerClass] hash] ^ [[self toViewControllerClass] hash] ^ [self transitionAction];
}
//重写equal 方法
- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[MSTransitionsData class]]) {
        return NO;
    }
    
    MSTransitionsData *otherObject = (MSTransitionsData *)object;
    
    return (otherObject.transitionAction & self.transitionAction) &&
    (otherObject.fromViewControllerClass == self.fromViewControllerClass) &&
    (otherObject.toViewControllerClass == self.toViewControllerClass);
}

@end


@interface MSControllerTransitioningDelegate()

@property (strong, nonatomic) NSMutableDictionary *animationDic;

@property (strong, nonatomic) NSMutableDictionary *interactionDic;

@property (strong, nonatomic) NSMutableDictionary *animationDirectionOverridesDic;

@end
@implementation MSControllerTransitioningDelegate

static MSControllerTransitioningDelegate *_defaultManager = nil;

+ (instancetype)shareInstance{
  
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[self alloc] init];
    });
    
    return _defaultManager;
}

- (instancetype)init{
    self = [super init];
    if ( self ) {
        self.animationDic = @{}.mutableCopy;
        self.interactionDic = @{}.mutableCopy;
        self.animationDirectionOverridesDic = @{}.mutableCopy;
    }
    return self;
}

- (MSTransitionsData *)animationController:(id<MSAnimationControllerProtocol>)animationController
                          fromViewController:(Class)fromViewController
                                   forAction:(MSTransitionAction)action{
    return [self animationController:animationController
                     fromViewController:fromViewController
                       toViewController:nil
                              forAction:action];
}

- (MSTransitionsData *)animationController:(id<MSAnimationControllerProtocol>)animationController
                          fromViewController:(Class)fromViewController
                            toViewController:(Class)toViewController
                                   forAction:(MSTransitionAction)action{
    MSTransitionsData *keyValue = nil;
    //左移运算<<  左移赋值<<= 按位与 &
    for ( NSUInteger x = 1; (x < (1 << (kMSTransitionActionCount - 1))); x <<= 1) {
        if ( action & x ) {
            if ( ((x & MSTransitionAction_Pop) && !(x & MSTransitionAction_Push)) ||
                ((x & MSTransitionAction_Dismiss) && !(x & MSTransitionAction_Present)) ) {
                
                keyValue = [[MSTransitionsData alloc] initWithAction:x withFromViewControllerClass:toViewController withToViewControllerClass:fromViewController];
            }else {
                keyValue = [[MSTransitionsData alloc] initWithAction:x withFromViewControllerClass:fromViewController withToViewControllerClass:toViewController];
            }
            [self.animationDic setObject:animationController forKey:keyValue];
        }
       
    }
    
    return keyValue;
}

- (MSTransitionsData *)interactionController:(id<MSTransitionInteractionControllerProtocol>)interactionController
                            fromViewController:(Class)fromViewController
                              toViewController:(Class)toViewController
                                     forAction:(MSTransitionAction)action{
    MSTransitionsData *keyValue = nil;
    
    for ( NSUInteger x = 1; (x < (1 << (kMSTransitionActionCount - 1)));  x <<= 1) {
        if ( action & x ) {
            MSTransitionsData *keyValue = nil;
            if ( ((x & MSTransitionAction_Pop) && !(x & MSTransitionAction_Push)) ||
                ((x & MSTransitionAction_Dismiss) && !(x & MSTransitionAction_Present)) ) {
                keyValue = [[MSTransitionsData alloc] initWithAction:x withFromViewControllerClass:toViewController withToViewControllerClass:fromViewController];
            }
            else {
                keyValue = [[MSTransitionsData alloc] initWithAction:x withFromViewControllerClass:fromViewController withToViewControllerClass:toViewController];
            }
            
            [self.interactionDic setObject:interactionController forKey:keyValue];
        }
    }
    
    return keyValue;
}

- (void)overrideAnimationDirection:(BOOL)isOverride withTransition:(MSTransitionsData *)transitionKey{
    [self.animationDirectionOverridesDic setObject:[NSNumber numberWithBool:isOverride] forKey:transitionKey];
}

#pragma mark - UIViewControllerTransitioningDelegate
//present
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    
    //生成key值
    MSTransitionsData *keyValue = [[MSTransitionsData alloc] initWithAction:MSTransitionAction_Present withFromViewControllerClass:[source class] withToViewControllerClass:[presented class]];
    
    id<MSAnimationControllerProtocol> animationController = (id<MSAnimationControllerProtocol>)[self.animationDic objectForKey:keyValue];
    if ( animationController == nil ) {
        keyValue.toViewControllerClass = nil;
        animationController = (id<MSAnimationControllerProtocol>)[self.animationDic objectForKey:keyValue];
    }
    if ( animationController == nil ) {
        animationController = self.defaultPresentDismissAnimationController;
    }
    
    if ( (animationController != nil) && (![[self.animationDirectionOverridesDic objectForKey:keyValue] boolValue]) ) {
        animationController.isPositiveAnimation = YES;
    }
    
    return animationController;
}
//dismiss
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    //生成key值
    MSTransitionsData *keyValue = [[MSTransitionsData alloc] initWithAction:MSTransitionAction_Dismiss withFromViewControllerClass:[dismissed class] withToViewControllerClass:nil];
    //找出动画
    id<MSAnimationControllerProtocol> animationController = nil;
    
    UIViewController *presentingViewController = dismissed.presentingViewController;
    
    if ([presentingViewController isKindOfClass:[UIViewController class]] ) {
        
        UIViewController *toViewController =[presentingViewController isKindOfClass:[UINavigationController class]]? (UIViewController *)[[presentingViewController childViewControllers] lastObject]:presentingViewController;
        if ( toViewController != nil ) {
            keyValue.toViewControllerClass = [toViewController class];
            animationController = (id<MSAnimationControllerProtocol>)[self.animationDic objectForKey:keyValue];
            if ( animationController == nil ) {
                keyValue.toViewControllerClass = nil;
                animationController = (id<MSAnimationControllerProtocol>)[self.animationDic objectForKey:keyValue];
            }
            if ( animationController == nil ) {
                keyValue.toViewControllerClass = [toViewController class];
                keyValue.fromViewControllerClass = nil;
                animationController = (id<MSAnimationControllerProtocol>)[self.animationDic objectForKey:keyValue];
            }
        }
    }
    if ( animationController == nil ) {
        keyValue.toViewControllerClass = nil;
        keyValue.fromViewControllerClass = [dismissed class];
        animationController = (id<MSAnimationControllerProtocol>)[self.animationDic objectForKey:keyValue];
        
    }
    if ( animationController == nil ) {
        animationController = self.defaultPresentDismissAnimationController;
    }
    
    if ( (animationController != nil) && (![[self.animationDirectionOverridesDic objectForKey:keyValue] boolValue]) ) {
        animationController.isPositiveAnimation = NO;
    }
    
    return animationController;
}
//交互转场 present
- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator{
    
    // 找到对应动画
    __block id returnInteraction = nil;
    [self.animationDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id<MSAnimationControllerProtocol> animationController = (id<MSAnimationControllerProtocol>)obj;
        MSTransitionsData *keyValue = (MSTransitionsData *)key;
        if ( animator == animationController && keyValue.transitionAction & MSTransitionAction_Present ) {
            id<MSTransitionInteractionControllerProtocol> interactionController = (id<MSTransitionInteractionControllerProtocol>)[self.interactionDic objectForKey:keyValue];
            
            if ( interactionController == nil ) {
                keyValue.toViewControllerClass = nil;
                interactionController = (id<MSTransitionInteractionControllerProtocol>)[self.interactionDic objectForKey:keyValue];
            }
            if( (interactionController != nil) && (interactionController.isInteractive) ) {
                returnInteraction = interactionController;
                *stop = YES;
            }
        }
    }];
    
    return returnInteraction;
}
//交互转场 dismiss
- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
    __block id returnInteraction = nil;
    [self.animationDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id<MSAnimationControllerProtocol> animationController = (id<MSAnimationControllerProtocol>)obj;
        MSTransitionsData *keyValue = (MSTransitionsData *)key;
        if ( animator == animationController && keyValue.transitionAction & MSTransitionAction_Dismiss ) {
            id<MSTransitionInteractionControllerProtocol> interactionController = (id<MSTransitionInteractionControllerProtocol>)[self.interactionDic objectForKey:keyValue];
            if ( interactionController == nil ) {
                keyValue.fromViewControllerClass = nil;
                interactionController = (id<MSTransitionInteractionControllerProtocol>)[self.interactionDic objectForKey:keyValue];
            }
            if( (interactionController != nil) && (interactionController.isInteractive) ) {
                returnInteraction = interactionController;
                *stop = YES;
            }
        }
    }];
    
    return returnInteraction;
}
#pragma mark UINavigationControllerDelegate  push-pop 的转场代理

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    
    //生成key值
    MSTransitionsData *keyValue = [[MSTransitionsData alloc] initWithAction:(operation == UINavigationControllerOperationPush) ? MSTransitionAction_Push : MSTransitionAction_Pop
                                              withFromViewControllerClass:[fromVC class]
                                                withToViewControllerClass:[toVC class]];
    //获取动画
    id<MSAnimationControllerProtocol> animationController = (id<MSAnimationControllerProtocol>)[self.animationDic objectForKey:keyValue];
    
    if ( animationController == nil ) {
        keyValue.toViewControllerClass = nil;
        animationController = (id<MSAnimationControllerProtocol>)[self.animationDic objectForKey:keyValue];
    }
    if (animationController == nil ) {
        keyValue.toViewControllerClass = [toVC class];
        keyValue.fromViewControllerClass = nil;
        animationController = (id<MSAnimationControllerProtocol>)[self.animationDic objectForKey:keyValue];
    }
    if ( animationController == nil ) {
        animationController = self.defaultPushPopAnimationController;
    }
    
    if ( ![[self.animationDirectionOverridesDic objectForKey:keyValue] boolValue] ) {
        if ( operation == UINavigationControllerOperationPush ) {
            animationController.isPositiveAnimation = YES;
        } else if ( operation == UINavigationControllerOperationPop )	{
            animationController.isPositiveAnimation = NO;
        }
    }
    
    return animationController;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController{
    return [self interactionControllerForAction:MSTransitionAction_PushPop withAnimationController:animationController];
}

//
#pragma mark UITabBarControllerDelegate 点击的转场代理

- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
                     animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                                       toViewController:(UIViewController *)toVC  NS_AVAILABLE_IOS(7_0){
    MSTransitionsData *keyValue = [[MSTransitionsData alloc] initWithAction:MSTransitionAction_Tab withFromViewControllerClass:[fromVC class] withToViewControllerClass:[toVC class]];
    id<MSAnimationControllerProtocol> animationController = (id<MSAnimationControllerProtocol>)[self.animationDic objectForKey:keyValue];
    if ( animationController == nil ) {
        keyValue.toViewControllerClass = nil;
        animationController = (id<MSAnimationControllerProtocol>)[self.animationDic objectForKey:keyValue];
    }
    if ( animationController == nil ) {
        animationController = self.defaultTabBarAnimationController;
    }
    
    NSUInteger fromVCIndex = [tabBarController.viewControllers indexOfObject:fromVC];
    NSUInteger toVCIndex = [tabBarController.viewControllers indexOfObject:toVC];
    
    if ( animationController && (![[self.animationDirectionOverridesDic objectForKey:keyValue] boolValue]) )
    {
        animationController.isPositiveAnimation = (fromVCIndex > toVCIndex);
    }
    
    return animationController;
}

- (id <UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController
                      interactionControllerForAnimationController: (id <UIViewControllerAnimatedTransitioning>)animationController NS_AVAILABLE_IOS(7_0){
    return [self interactionControllerForAction:MSTransitionAction_Tab withAnimationController:animationController];
}
#pragma mark - 匹配对应事件的交换转场

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForAction:(MSTransitionAction)action withAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController{
    for ( MSTransitionsData * key in self.interactionDic ) {
        id<MSTransitionInteractionControllerProtocol> interactionController = [self.interactionDic objectForKey:key];
        if ( (interactionController.action & action) && [interactionController isInteractive] ) {
            return interactionController;
        }
    }
    
    return nil;
}

@end

@implementation NSObject (MSTransitions)

- (UIView *)toView{
    return [self viewTo:YES];
}

- (UIView *)fromView{
    return [self viewTo:NO];
}

- (UIView *)viewTo:(BOOL)isTo{
    NSAssert([self conformsToProtocol:@protocol(UIViewControllerContextTransitioning)], @"bad parameter");
    if (![self conformsToProtocol:@protocol(UIViewControllerContextTransitioning)]) {
        return nil;
    }
    id<UIViewControllerContextTransitioning> context = (id<UIViewControllerContextTransitioning>)self;
    
    NSString *vcKey = isTo ? UITransitionContextToViewControllerKey : UITransitionContextFromViewControllerKey;
    UIViewController *vc = [context viewControllerForKey:vcKey];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([context respondsToSelector:@selector(viewForKey:)]) {
        NSString *vKey = isTo ? UITransitionContextToViewKey : UITransitionContextFromViewKey;
        return [context viewForKey:vKey];
    }else {
        return vc.view;
    }
#else
    return vc.view;
#endif
}


@end
