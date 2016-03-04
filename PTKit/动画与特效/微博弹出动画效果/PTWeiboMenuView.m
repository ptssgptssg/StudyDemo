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
#define PTWeiboMenuViewAnimationTime 0.36
#define PTWeiboMenuViewAnimationInterval (PTWeiboMenuViewAnimationTime/5)
#define PTWeiboMenuViewRiseAnimationID @"PTWeiboMenuViewRiseAnimationID"
#define PTWeiboMenuViewDropAnimationID @"PTWeiboMenuViewDropAnimationID"

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

@interface PTWeiboMenuView ()<UIGestureRecognizerDelegate> {
    NSMutableArray *buttons;
    UIImageView *backgroundImage;
}
@end

@implementation PTWeiboMenuView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        buttons = [NSMutableArray array];
        backgroundImage = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:backgroundImage];
        self.backgroundColor = [UIColor blackColor];
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
    NSInteger rowCount = buttons.count/PTWeiboMenuViewColumnCount + (buttons.count%PTWeiboMenuViewColumnCount>0?1:0);
    
    for (NSInteger i = 0; i < buttons.count; i++) {
        NSInteger columnIndex = i % PTWeiboMenuViewColumnCount;
        NSInteger rowIndex = i / PTWeiboMenuViewColumnCount;
        
        PTWeiboButton *button = buttons[i];
        button.layer.opacity = 0.0f;
        CGRect frame = [self frameForButtonAtIndex:i];
        
        CGPoint fromPosition = CGPointMake(frame.origin.x+PTWeiboMenuViewImageHeight/2.0f, frame.origin.y+(PTWeiboMenuViewImageHeight+PTWeiboMenuViewTitleHeight)/2.0f+(rowCount-rowIndex+2)*200);
        CGPoint toPosition = CGPointMake(frame.origin.x+PTWeiboMenuViewImageHeight/2.0f, frame.origin.y+(PTWeiboMenuViewImageHeight+PTWeiboMenuViewTitleHeight)/2.0f);
        
        double delayInSeconds = rowIndex * PTWeiboMenuViewColumnCount * PTWeiboMenuViewAnimationInterval;
        if (!columnIndex) {
            delayInSeconds += PTWeiboMenuViewAnimationInterval;
        }else if (columnIndex == 2) {
            delayInSeconds += PTWeiboMenuViewAnimationInterval * 2;
        }
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
        positionAnimation.duration = PTWeiboMenuViewAnimationTime;
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.45f :1.2f :0.75f :1.0f];
        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
        [positionAnimation setValue:[NSNumber numberWithInteger:i] forKey:PTWeiboMenuViewRiseAnimationID];
        positionAnimation.delegate = self;
        
        [button.layer addAnimation:positionAnimation forKey:@"riseAnimation"];
    }
}

- (void)dropAnimation {
    NSInteger rowCount = buttons.count/PTWeiboMenuViewColumnCount + (buttons.count%PTWeiboMenuViewColumnCount>0?1:0);
    
    for (NSInteger i = 0; i < buttons.count; i++) {
        NSInteger columnIndex = i % PTWeiboMenuViewColumnCount;
        NSInteger rowIndex = i / PTWeiboMenuViewColumnCount;
        
        PTWeiboButton *button = buttons[i];
        CGRect frame = [self frameForButtonAtIndex:i];
        
        CGPoint fromPosition = CGPointMake(frame.origin.x+PTWeiboMenuViewImageHeight/2.0f, frame.origin.y+(PTWeiboMenuViewImageHeight+PTWeiboMenuViewTitleHeight)/2.0f);
        CGPoint toPosition = CGPointMake(frame.origin.x+PTWeiboMenuViewImageHeight/2.0f, frame.origin.y+(PTWeiboMenuViewImageHeight+PTWeiboMenuViewTitleHeight)/2.0f+(rowCount-rowIndex+2)*200);
        
        double delayInSeconds = rowIndex * PTWeiboMenuViewColumnCount * PTWeiboMenuViewAnimationInterval;
        if (!columnIndex) {
            delayInSeconds += PTWeiboMenuViewAnimationInterval;
        }else if (columnIndex == 2) {
            delayInSeconds += PTWeiboMenuViewAnimationInterval * 2;
        }
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
        positionAnimation.duration = PTWeiboMenuViewAnimationTime;
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.45f :1.2f :0.75f :1.0f];
        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil]+delayInSeconds;
        [positionAnimation setValue:[NSNumber numberWithInteger:i] forKey:PTWeiboMenuViewDropAnimationID];
        positionAnimation.delegate = self;
        
        [button.layer addAnimation:positionAnimation forKey:@"dropAnimation"];
    }
}

- (void)animationDidStart:(CAAnimation *)anim {
    if ([anim valueForKey:PTWeiboMenuViewRiseAnimationID]) {
        NSInteger index = [[anim valueForKey:PTWeiboMenuViewRiseAnimationID]integerValue];
        
        PTWeiboButton *button = buttons[index];
        
        CGFloat toAlpha = 1.0f;
        button.layer.opacity = toAlpha;
    }else if ([anim valueForKey:PTWeiboMenuViewDropAnimationID]) {
        NSInteger index = [[anim valueForKey:PTWeiboMenuViewDropAnimationID]integerValue];
        NSInteger rowCount = buttons.count/PTWeiboMenuViewColumnCount + (buttons.count%PTWeiboMenuViewColumnCount>0?1:0);
        NSInteger rowIndex = index / PTWeiboMenuViewColumnCount;
        
        PTWeiboButton *button = buttons[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        
        CGPoint toPosition = CGPointMake(frame.origin.x+PTWeiboMenuViewImageHeight/2.0f, frame.origin.y+(PTWeiboMenuViewImageHeight+PTWeiboMenuViewTitleHeight)/2.0f+(rowCount-rowIndex+2)*200);
        button.layer.position = toPosition;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (NSInteger i = 0; i < buttons.count; i++) {
        PTWeiboButton *button = buttons[i];
        button.frame = [self frameForButtonAtIndex:i];
    }
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIViewController *appRootViewController = window.rootViewController;
    
    UIViewController *topViewController = appRootViewController;
    while (topViewController.presentedViewController != nil) {
        topViewController = topViewController.presentedViewController;
    }
    
    self.frame = topViewController.view.bounds;
    [topViewController.view addSubview:self];
    
    [self riseAnimation];
}

- (void)dismiss:(UITapGestureRecognizer *)sender {
    [self dropAnimation];
    double delayInSeconds = PTWeiboMenuViewAnimationTime + PTWeiboMenuViewAnimationInterval * (buttons.count + 1);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

- (void)buttonClick:(PTWeiboButton *)sender {
    [self dismiss:nil];
    sender.selectedBlock();
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer.view isKindOfClass:[PTWeiboButton class]]) {
        return NO;
    }
    
    CGPoint location = [gestureRecognizer locationInView:self];
    for (UIView *subview in buttons) {
        if (CGRectContainsPoint(subview.frame, location)) {
            return NO;
        }
    }
    
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
