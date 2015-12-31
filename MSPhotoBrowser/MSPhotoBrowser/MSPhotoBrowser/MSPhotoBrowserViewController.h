//
//  MSPhotoBrowserViewController.h
//  MSPhotoBrowser
//
//  Created by liqian on 15/11/27.
//  Copyright © 2015年 Bestdo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MSPhotoBrowserDataSource;
@protocol MSPhotoBrowserDelegate;

@interface MSPhotoBrowserViewController : UIPageViewController


@property (nonatomic, weak) id<MSPhotoBrowserDataSource> ms_dataSource;
@property (nonatomic, weak) id<MSPhotoBrowserDelegate> ms_delegate;

@property (nonatomic, assign) NSInteger currentPage;

@end


//数据源协议
@protocol MSPhotoBrowserDataSource <NSObject>
//图片或图片url 的 总数
- (NSInteger)numberOfPagesInViewController:(MSPhotoBrowserViewController *)viewController;

@optional
//Index对应的图片
- (UIImage *)viewController:(MSPhotoBrowserViewController *)viewController imageForPageAtIndex:(NSInteger)index;

//presenting 的imageView 对象
- (void)viewController:(MSPhotoBrowserViewController *)viewController presentImageView:(UIImageView *)imageView forPageAtIndex:(NSInteger)index;
@end

//事件 自定义协议
@protocol MSPhotoBrowserDelegate <NSObject>

// 单击
- (void)viewController:(MSPhotoBrowserViewController *)viewController didSingleTapedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage;

@optional

// 长按
- (void)viewController:(MSPhotoBrowserViewController *)viewController didLongPressedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage;

//顶部视图的高 默认 y 20
- (CGFloat)viewController:(MSPhotoBrowserViewController *)viewController heightForTopViewAtIndex:(NSInteger)index;
//底部视图的高
- (CGFloat)viewController:(MSPhotoBrowserViewController *)viewController heightForBottomViewAtIndex:(NSInteger)index;

//自定义顶部视图
- (UIView *)viewController:(MSPhotoBrowserViewController *)viewController topViewForPageAtIndex:(NSInteger)index;
//自定义底部视图
- (UIView *)viewController:(MSPhotoBrowserViewController *)viewController bottomViewForPageAtIndex:(NSInteger)index;
@end


