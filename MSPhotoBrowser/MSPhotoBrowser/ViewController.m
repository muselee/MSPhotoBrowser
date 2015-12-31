//
//  ViewController.m
//  MSPhotoBrowser
//
//  Created by liqian on 15/12/30.
//  Copyright © 2015年 Bestdo. All rights reserved.
//

#import "ViewController.h"
#import "MSPhotoBrowser/MSPhotoBrowserViewController.h"
#import "MSControllerTransitioningDelegate.h"
#import "MSCircleAnimationController.h"
#import "MSZoomAlphaAnimationController.h"
@interface ViewController ()<MSPhotoBrowserDataSource,MSPhotoBrowserDelegate>
@property (nonatomic, strong) NSArray *images;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
//     [[MSControllerTransitioningDelegate shareInstance] animationController:[MSZoomAlphaAnimationController new]fromViewController:[self class]forAction:MSTransitionAction_PresentDismiss];
    
    [[MSControllerTransitioningDelegate shareInstance] animationController:[MSCircleAnimationController new]fromViewController:[self class]forAction:MSTransitionAction_PresentDismiss];
    
}
- (IBAction)present:(id)sender {
    
    MSPhotoBrowserViewController * ms = [[MSPhotoBrowserViewController alloc]init];
    ms.ms_dataSource = self;
    ms.ms_delegate = self;
    ms.currentPage = 2;
    ms.transitioningDelegate = [MSControllerTransitioningDelegate shareInstance];
    [self presentViewController:ms animated:YES completion:nil];
    
}

#pragma mark - MSPhotoBrowserDataSource

- (NSInteger)numberOfPagesInViewController:(MSPhotoBrowserViewController *)viewController {
    return self.images.count;
}

- (UIImage *)viewController:(MSPhotoBrowserViewController *)viewController imageForPageAtIndex:(NSInteger)index{
    return [UIImage imageNamed:_images[index]];
}

//- (void)viewController:(MSPhotoBrowserViewController *)viewController presentImageView:(UIImageView *)imageView forPageAtIndex:(NSInteger)index {
//    imageView.image = [UIImage imageNamed:_images[index]];
//    
//}



#pragma mark - MSPhotoBrowserDelegate

- (void)viewController:(MSPhotoBrowserViewController *)viewController didSingleTapedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)viewController:(MSPhotoBrowserViewController *)viewController heightForBottomViewAtIndex:(NSInteger)index {
    return 44;
}

- (UIView *)viewController:(MSPhotoBrowserViewController *)viewController bottomViewForPageAtIndex:(NSInteger)index{
    
    UILabel * label = [[UILabel alloc]init];
    label.backgroundColor= [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"%ld / %lu",(long)index+1,(unsigned long)_images.count];
    return label;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark property
- (NSArray *)images {
    if (!_images) {
        _images = @[@"b0",@"b1",@"b2",@"b3",@"b4",@"b5",@"b6",@"b7",@"b8",@"b9"];
    }
    return _images;
}


@end
