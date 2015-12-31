//
//  MSPhotoScrollerViewController.h
//  MSPhotoBrowser
//
//  Created by liqian on 15/11/27.
//  Copyright © 2015年 Bestdo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSPhotoScrollerViewController : UIViewController
 /** 当前page*/
@property (nonatomic, assign) NSInteger page;
 /** 获取当前图片*/
@property (nonatomic, copy) UIImage *(^fetchImageBlock)(void);
 /** 设置当前图片*/
@property (nonatomic, copy) void (^configureImageViewBlock)(UIImageView *imageView);
 /** 获取当前顶部view*/
@property (nonatomic, copy) UIView * (^fetchTopViewBlock)(void);
 /** 获取当前底部view*/
@property (nonatomic, copy) UIView * (^fetchBottomViewBlock)(void);
 /** 获取顶部视图高度*/
@property (nonatomic, copy) CGFloat (^fetchTopViewHeightBlock)(void);
 /** 获取底部视图高度*/
@property (nonatomic, copy) CGFloat (^fetchBottomViewHeightBlock)(void);
 /** 单击*/
@property (nonatomic, copy) void (^didSingleTaped)(UIImage *image);
 /** 长按*/
@property (nonatomic, copy) void (^didLongPressed)(UIImage *image);
@end
