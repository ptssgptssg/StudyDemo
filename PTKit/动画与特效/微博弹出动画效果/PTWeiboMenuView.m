//
//  PTWeiboMenuView.m
//  PTKit
//
//  Created by 彭腾 on 16/3/1.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "PTWeiboMenuView.h"

#define PTWeiboMenuViewImageHeight 90
#define PTWeiboMenuViewTitleHeight 20
#define PTWeiboMenuViewColumnCount 3
#define PTWeiboMenuViewHorizontalMargin 10
#define PTWeiboMenuViewVerticalPadding 10

@interface PTWeiboButton : UIButton

+(id)itemWithTitle:(NSString *)title andIcon:(UIImage *)icon andSelectedBlock:(PTWeiboMenuViewCompletionBlock)block;

@property (nonatomic, copy) PTWeiboMenuViewCompletionBlock selectedBlock;

@end

@implementation PTWeiboButton

+ (id)itemWithTitle:(NSString *)title andIcon:(UIImage *)icon andSelectedBlock:(PTWeiboMenuViewCompletionBlock)block {
    PTWeiboButton *button = [PTWeiboButton buttonWithType:UIButtonTypeCustom];
    
    [button setImage:icon forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.selectedBlock = block;
    
    return button;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, PTWeiboMenuViewImageHeight, PTWeiboMenuViewImageHeight);
    self.titleLabel.frame = CGRectMake(0, PTWeiboMenuViewImageHeight, PTWeiboMenuViewImageHeight, PTWeiboMenuViewTitleHeight);
}

@end

@interface PTWeiboMenuView () {
    NSMutableArray *buttons;
    UIImageView *backgroundImage;
}
@end

@implementation PTWeiboMenuView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        buttons = [NSMutableArray array];
        backgroundImage = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:backgroundImage];
    }
    return self;
}

- (void)addItemWithTitle:(NSString *)title andIcon:(UIImage *)icon andSelectedBlock:(PTWeiboMenuViewCompletionBlock)block {
    PTWeiboButton *button = [PTWeiboButton itemWithTitle:title andIcon:icon andSelectedBlock:block];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    [buttons addObject:button];
}

- (CGRect)frameForButtonAtIndex:(NSInteger)index {
    NSInteger columnIndex = index % PTWeiboMenuViewColumnCount;
    
    NSInteger rowCount = buttons.count/PTWeiboMenuViewColumnCount + (buttons.count%PTWeiboMenuViewColumnCount>0?1:0);
    NSInteger rowIndex = index / PTWeiboMenuViewColumnCount;
    
    CGFloat itemHeight = (PTWeiboMenuViewImageHeight + PTWeiboMenuViewTitleHeight) * rowCount + (rowCount > 1?(rowCount - 1) * PTWeiboMenuViewVerticalPadding:0);
    CGFloat horizontalMargin = (self.frame.size.width - PTWeiboMenuViewHorizontalMargin*2 - PTWeiboMenuViewImageHeight*PTWeiboMenuViewColumnCount) / 2.0f;

    CGFloat offsetX = PTWeiboMenuViewHorizontalMargin;
    offsetX += (PTWeiboMenuViewImageHeight + horizontalMargin) * columnIndex;
    
    CGFloat offsetY = (self.frame.size.height - itemHeight) / 2.0f;
    offsetY += (PTWeiboMenuViewImageHeight + PTWeiboMenuViewTitleHeight + PTWeiboMenuViewVerticalPadding) * rowIndex;
    
    return CGRectMake(offsetX, offsetY, PTWeiboMenuViewImageHeight, PTWeiboMenuViewImageHeight+PTWeiboMenuViewTitleHeight);
}

- (void)riseAnimation {
    
}

- (void)dropAnimation {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (NSInteger i = 0; i < buttons.count; i++) {
        PTWeiboButton *button = buttons[i];
        button.frame = [self frameForButtonAtIndex:i];
    }
}

- (void)show {
    
}

- (void)buttonClick:(UIButton *)sender {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
