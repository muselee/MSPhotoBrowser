//
//  MSPhotoScrollerViewController.m
//  MSPhotoBrowser
//
//  Created by liqian on 15/11/27.
//  Copyright © 2015年 Bestdo. All rights reserved.
//

#import "MSPhotoScrollerViewController.h"

static NSString * const MSObservedKeyPath = @"imageView.image";

@interface MSPhotoScrollerViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation MSPhotoScrollerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.scrollView addSubview:self.imageView];
    [self.view addSubview:self.scrollView];
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.scrollView addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.scrollView addGestureRecognizer:singleTap];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self prepareForReuse];
    
    if (self.fetchImageBlock) {
        self.imageView.image = self.fetchImageBlock();
    }
    if (self.configureImageViewBlock) {
        self.configureImageViewBlock(self.imageView);
    }

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self setZoomParametersForSize:self.scrollView.bounds.size];
    CGFloat zoomScale = self.scrollView.zoomScale;
    CGFloat minimumZoomScale = self.scrollView.minimumZoomScale;
    if (zoomScale < minimumZoomScale) {
        self.scrollView.zoomScale = minimumZoomScale;
    }
    [self recenterImage];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Inner methods

- (void)setZoomParametersForSize:(CGSize)scrollViewSize {
    CGSize imageSize = self.imageView.bounds.size;
    
    CGFloat widthScale = scrollViewSize.width / imageSize.width;
    CGFloat heightScale = scrollViewSize.height / imageSize.height;
    CGFloat minScale = MIN(widthScale, heightScale);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 2.0;
}

- (void)recenterImage {
    CGSize scrollViewSize = self.scrollView.bounds.size;
    CGSize imageSize = self.imageView.frame.size;
    
    CGFloat horizontalSpace = imageSize.width < scrollViewSize.width ?
    (scrollViewSize.width - imageSize.width) / 2 : 0;
    CGFloat verticalSpace = imageSize.height < scrollViewSize.height ?
    (scrollViewSize.height - imageSize.height) / 2 : 0;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(verticalSpace, horizontalSpace, verticalSpace, horizontalSpace);
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    if (self.didSingleTaped) {
        self.didSingleTaped(self.imageView.image);
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)sender {
    if (!self.imageView.image) {
        return;
    }
    
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        [self zoomRectWithCenter:[sender locationInView:self.imageView]];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    if (self.didLongPressed) {
        self.didLongPressed(self.imageView.image);
    }
}

- (void)zoomRectWithCenter:(CGPoint)center{
    CGRect rect;
    CGFloat zoomScale = self.scrollView.minimumZoomScale * 3;
    rect.size = CGSizeMake(self.scrollView.frame.size.width / zoomScale, self.scrollView.frame.size.height / zoomScale);
    rect.origin.x = MAX((center.x - (rect.size.width / 2.0f)), 0.0f);
    rect.origin.y = MAX((center.y - (rect.size.height / 2.0f)), 0.0f);
    
    CGRect frame = [self.scrollView.superview convertRect:self.scrollView.frame toView:self.scrollView.superview];
    CGFloat borderX = frame.origin.x;
    CGFloat borderY = frame.origin.y;
    
    if (borderX > 0.0f && (center.x < borderX || center.x > self.scrollView.frame.size.width - borderX)) {
        if (center.x < (self.scrollView.frame.size.width / 2.0f)) {
            rect.origin.x += (borderX / zoomScale);
        } else {
            rect.origin.x -= ((borderX / zoomScale) + rect.size.width);
        }
    }
    
    if (borderY > 0.0f && (center.y < borderY || center.y > self.scrollView.frame.size.height - borderY)) {
        if (center.y < (self.scrollView.frame.size.height / 2.0f)) {
            rect.origin.y += (borderY / zoomScale);
        } else {
            rect.origin.y -= ((borderY / zoomScale) + rect.size.height);
        }
    }
    
    [self.scrollView zoomToRect:rect animated:YES];
}

- (void)prepareForReuse {
    self.imageView.image = nil;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self recenterImage];
}

#pragma mark - Accessor

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

@end
