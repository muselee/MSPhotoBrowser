//
//  MSPhotoBrowserViewController.m
//  MSPhotoBrowser
//
//  Created by liqian on 15/11/27.
//  Copyright © 2015年 Bestdo. All rights reserved.
//

#import "MSPhotoBrowserViewController.h"
#import "MSPhotoScrollerViewController.h"

static CGFloat const defaultTopBottomViewHeight = 44;

#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif

@interface MSPhotoBrowserViewController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic, strong) NSArray *reusableImageScrollerViewControllers;
@property (nonatomic, assign) NSInteger numberOfPages;
@end
@implementation MSPhotoBrowserViewController

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
                  navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                                options:(NSDictionary<NSString *,id> *)options{
    
    options = options ?: @{};
    NSMutableDictionary *dict = [options mutableCopy];
    [dict setObject:@(20) forKey:UIPageViewControllerOptionInterPageSpacingKey];
    
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:navigationOrientation
                                  options:dict];
    _currentPage = 0;
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidLoad{
    
    // 获取图片总数
    if (self.ms_dataSource && [self.ms_dataSource conformsToProtocol:@protocol(MSPhotoBrowserDataSource)] &&
        [self.ms_dataSource respondsToSelector:@selector(numberOfPagesInViewController:)]) {
        self.numberOfPages = [self.ms_dataSource numberOfPagesInViewController:self];
    }
    
    // 获取需要显示的图片VC
    self.currentPage = 0 < self.currentPage && self.currentPage < self.numberOfPages ? self.currentPage : 0;
    MSPhotoScrollerViewController *firstImageScrollerViewController = [self imageScrollerViewControllerForPage:self.currentPage];
    if (firstImageScrollerViewController==nil) {
        return;
    }
    [self setViewControllers:@[firstImageScrollerViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    //设置UIPageViewController的数据源和代理
    self.dataSource = self;
    self.delegate = self;
   
}


#pragma mark public
- (void)setCurrentPage:(NSInteger)currentPage{
    _currentPage = currentPage;
}
#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(MSPhotoScrollerViewController *)viewController {
    return [self imageScrollerViewControllerForPage:viewController.page-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(MSPhotoScrollerViewController *)viewController {
    return [self imageScrollerViewControllerForPage:viewController.page+1];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    MSPhotoScrollerViewController *imageScrollerViewController = pageViewController.viewControllers.firstObject;
    self.currentPage = imageScrollerViewController.page;
}
#pragma mark inner
- (MSPhotoScrollerViewController *)imageScrollerViewControllerForPage:(NSInteger)page {
    if (page > self.numberOfPages-1 ||
        page < 0) {
        return nil;
    }
    
    NSInteger index = page % 3;
    // 获取重用 MSPhotoScrollerViewController
    MSPhotoScrollerViewController *imageScrollerViewController = [self.reusableImageScrollerViewControllers objectAtIndex:index];
    
    @weakify(self)
    // 设置数据源
    if (self.ms_dataSource &&
        [self.ms_dataSource conformsToProtocol:@protocol(MSPhotoBrowserDataSource)]) {
        
        imageScrollerViewController.page = page;
        //获取当前图片
        if ([self.ms_dataSource respondsToSelector:@selector(viewController:imageForPageAtIndex:)]) {
            imageScrollerViewController.fetchImageBlock = ^UIImage*(void) {
               @strongify(self)
                UIImage *image = [self.ms_dataSource viewController:self imageForPageAtIndex:page];
                return image;
            };
        }
        //获取当前imageView
        if ([self.ms_dataSource respondsToSelector:@selector(viewController:presentImageView:forPageAtIndex:)]) {
            imageScrollerViewController.configureImageViewBlock = ^(UIImageView *imageView) {
                 @strongify(self)
                [self.ms_dataSource viewController:self presentImageView:imageView forPageAtIndex:page];
            };
        }
    }
    // 设置代理
    if (self.ms_delegate &&
        [self.ms_delegate conformsToProtocol:@protocol(MSPhotoBrowserDelegate)]) {
        
        //单击
        if ([self.ms_delegate respondsToSelector:@selector(viewController:didSingleTapedPageAtIndex:presentedImage:)]) {
            imageScrollerViewController.didSingleTaped = ^(UIImage *image) {
                @strongify(self)
                [self.ms_delegate viewController:self didSingleTapedPageAtIndex:page presentedImage:image];
            };
        }
        //长按
        if ([self.ms_delegate respondsToSelector:@selector(viewController:didLongPressedPageAtIndex:presentedImage:)]) {
            imageScrollerViewController.didLongPressed = ^(UIImage *image) {
                 @strongify(self)
                [self.ms_delegate viewController:self didLongPressedPageAtIndex:page presentedImage:image];
            };
        }
        //顶部view
        if ([self.ms_delegate respondsToSelector:@selector(viewController:heightForTopViewAtIndex:)]) {
            
            imageScrollerViewController.fetchTopViewHeightBlock = ^CGFloat(void) {
                @strongify(self)
                CGFloat height = [self.ms_delegate viewController:self heightForTopViewAtIndex:page];
                return height;
            };
        }
        
        if ([self.ms_delegate respondsToSelector:@selector(viewController:topViewForPageAtIndex:)]) {
            imageScrollerViewController.fetchTopViewBlock = ^UIView *(void) {
                @strongify(self)
                UIView * topView = [self.ms_delegate viewController:self topViewForPageAtIndex:page];
                return topView;
            };
        }

        //底部view
        if ([self.ms_delegate respondsToSelector:@selector(viewController:heightForBottomViewAtIndex:)]) {
            imageScrollerViewController.fetchBottomViewHeightBlock = ^CGFloat(void) {
                @strongify(self)
                CGFloat height = [self.ms_delegate viewController:self heightForBottomViewAtIndex:page];
                return height?:defaultTopBottomViewHeight;
            };
        }
        
        if ([self.ms_delegate respondsToSelector:@selector(viewController:bottomViewForPageAtIndex:)]) {
            imageScrollerViewController.fetchBottomViewBlock = ^UIView *(void) {
                @strongify(self)
                UIView * bottomView = [self.ms_delegate viewController:self bottomViewForPageAtIndex:page];
                return bottomView;
            };
        }
    }
    
    return imageScrollerViewController;
}

#pragma mark 重用图片展示VC
- (NSArray *)reusableImageScrollerViewControllers {
    if (!_reusableImageScrollerViewControllers) {
        NSMutableArray *controllers = [NSMutableArray new];
        for (NSInteger index = 0; index < 3; index++) {
            MSPhotoScrollerViewController *imageScrollerViewController = [MSPhotoScrollerViewController new];
            imageScrollerViewController.page = index;
            [controllers addObject:imageScrollerViewController];
        }
        _reusableImageScrollerViewControllers = [NSArray arrayWithArray:controllers];
    }
    return _reusableImageScrollerViewControllers;
}
@end
