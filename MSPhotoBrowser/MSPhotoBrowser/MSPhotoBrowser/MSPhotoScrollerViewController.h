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

 /** 单击*/
@property (nonatomic, copy) void (^didSingleTaped)(UIImage *image);
 /** 长按*/
@property (nonatomic, copy) void (^didLongPressed)(UIImage *image);
@end
