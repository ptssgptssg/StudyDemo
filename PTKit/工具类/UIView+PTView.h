//
//  UIView+PTView.h
//  PTKit
//
//  Created by 彭腾 on 16/3/3.
//  Copyright © 2016年 PT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PTView)
/**
 *  frame.origin.x
 */
@property (nonatomic) CGFloat left;
/**
 *  frame.origin.y
 */
@property (nonatomic) CGFloat top;
/**
 *  frame.origin.x+frame.size.width
 */
@property (nonatomic) CGFloat right;
/**
 *  frame.origin.y+frame.size.height
 */
@property (nonatomic) CGFloat bottom;
/**
 *  frame.size.width
 */
@property (nonatomic) CGFloat width;
/**
 *  frame.size.height
 */
@property (nonatomic) CGFloat height;
/**
 *  center.x
 */
@property (nonatomic) CGFloat centerX;
/**
 *  center.y
 */
@property (nonatomic) CGFloat centerY;
/**
 *  frame.origin
 */
@property (nonatomic) CGPoint origin;
/**
 *  frame.size
 */
@property (nonatomic) CGSize  size;

@end
