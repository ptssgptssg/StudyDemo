//
//  PTLabel.h
//  PTKit
//
//  Created by 彭腾 on 16/3/25.
//  Copyright © 2016年 PT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTLabel : UIView

@property (nonatomic, copy) NSString *text;

@property (nonatomic, copy) NSAttributedString *attributedText;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic) NSInteger numberOfLines;

@end
