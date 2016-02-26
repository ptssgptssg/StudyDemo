//
//  UIViewController+PopAnimation.m
//  PTKit
//
//  Created by 彭腾 on 16/2/24.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "UIViewController+PopAnimation.h"

const struct PTPopViewOptionKeys PTPopViewOptionKeys = {
    .backgroundView = @"PTPopViewOptionBackgroundView",
};

#define PTPopViewOverlayTag 1000
#define PTPopViewDismissButtonTag 1001
#define PTPopViewScreenshotTag 1002
#define PTPopViewTag 1003

@implementation UIViewController (PopAnimation)

- (UIViewController *)parentTargetViewController {
    UIViewController *target = self;
    while (target.parentViewController != nil) {
        target = target.parentViewController;
    }
    return target;
}

- (UIView *)parentTarget {
    return [self parentViewController].view;
}

- (void)presentPopViewController:(UIViewController *)vc {
    [self presentPopViewController:vc withOptions:nil completion:nil dimissBlock:nil];
}

- (void)presentPopViewController:(UIViewController *)vc withOptions:(NSDictionary *)options {
    [self presentPopViewController:vc withOptions:options completion:nil dimissBlock:nil];
}

- (void)presentPopViewController:(UIViewController *)vc
                     withOptions:(NSDictionary *)options
                      completion:(PTTransitionCompletionBlock)completion
                     dimissBlock:(PTTransitionCompletionBlock)dismissBlock {
    UIViewController *targetVC = [self parentTargetViewController];
    [targetVC addChildViewController:vc];
    [self presentPopView:vc.view withOptions:options completion:^{
        [vc didMoveToParentViewController:targetVC];
        if (completion) {
            completion();
        }
    }];
}

- (void)presentPopView:(UIView *)view {
    [self presentPopView:view withOptions:nil completion:nil];
}

- (void)presentPopView:(UIView *)view withOptions:(NSDictionary *)options {
    [self presentPopView:view withOptions:options completion:nil];
}

- (void)presentPopView:(UIView *)view
           withOptions:(NSDictionary *)options
            completion:(PTTransitionCompletionBlock)completion {
    UIView *target = [self parentTarget];
    if (![target.subviews containsObject:view]) {
        
        CGFloat popViewHeight = view.frame.size.height;
        CGRect vf = target.bounds;
        CGRect popViewFrame = CGRectMake(0, vf.size.height-popViewHeight, vf.size.width, popViewHeight);
        
        CGRect overlayFrame = CGRectMake(0, 0, vf.size.width, vf.size.height-popViewHeight);
        
        UIView *overlay;
        UIView *backgroundView = options[PTPopViewOptionKeys.backgroundView];
        if (backgroundView) {
            overlay = backgroundView;
        }else {
            overlay = [[UIView alloc]init];
        }
        
        overlay.frame = target.bounds;
        overlay.backgroundColor = [UIColor blackColor];
        overlay.userInteractionEnabled = YES;
        overlay.tag = PTPopViewOverlayTag;
        
        UIImageView *ss = [self addScreenshowInView:overlay];
        [target addSubview:overlay];
        
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissButton.frame = overlayFrame;
        dismissButton.backgroundColor = [UIColor clearColor];
        [dismissButton addTarget:self action:@selector(dismissPopView) forControlEvents:UIControlEventTouchUpInside];
        dismissButton.tag = PTPopViewDismissButtonTag;
        [overlay addSubview:dismissButton];
        
        [ss.layer addAnimation:[self animationGroupForward:YES] forKey:@"pushedBackAnimation"];
        
        NSTimeInterval duration = 0.5;
        [UIView animateWithDuration:duration animations:^{
            ss.alpha = 0.5;
        }];
        
        view.frame = CGRectOffset(popViewFrame, 0, popViewHeight);
        view.tag = PTPopViewTag;
        [target addSubview:view];
        view.layer.shadowColor = [[UIColor blackColor]CGColor];
        view.layer.shadowOffset = CGSizeMake(0, -2);
        view.layer.shadowRadius = 5.0;
        view.layer.shadowOpacity = 0.8;
        view.layer.shouldRasterize = YES;
        view.layer.rasterizationScale = [[UIScreen mainScreen]scale];
        
        [UIView animateWithDuration:duration animations:^{
            view.frame = popViewFrame;
        } completion:^(BOOL finished) {
            if (finished) {
                if (completion) {
                    completion();
                }
            }
        }];
    }
}

- (void)dismissPopView {
    [self dismissPopViewWithCompletion:nil];
}

- (void)dismissPopViewWithCompletion:(PTTransitionCompletionBlock)completion {
    UIView *target = [self parentTarget];
    UIView *modal = [target viewWithTag:PTPopViewTag];
    UIView *overlay = [target viewWithTag:PTPopViewOverlayTag];
    NSTimeInterval duration = 0.5;
    
    [UIView animateWithDuration:duration animations:^{
        modal.frame = CGRectMake(0, target.bounds.size.height, modal.frame.size.width, modal.frame.size.height);
    } completion:^(BOOL finished) {
        [modal removeFromSuperview];
        [overlay removeFromSuperview];
    }];
    
    UIImageView *ss = (UIImageView *)[overlay.subviews objectAtIndex:0];
    [ss.layer addAnimation:[self animationGroupForward:NO] forKey:@"bringForwardAnimation"];
    [UIView animateWithDuration:duration animations:^{
        ss.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            if (completion) {
                completion();
            }
        }
    }];
}

- (CAAnimationGroup *)animationGroupForward:(BOOL)forward {
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0/-900;
    t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
    t1 = CATransform3DRotate(t1, 15.0f*M_PI/180.0f, 1, 0, 0);
    
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = t1.m34;
    double scale = 0.8;
    t2 = CATransform3DTranslate(t2, 0, [self parentTarget].frame.size.height*-0.08, 0);
    t2 = CATransform3DScale(t2, scale, scale, 1);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:t1];
    CFTimeInterval duration = 0.5;
    animation.duration = duration/2;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation2.toValue = [NSValue valueWithCATransform3D:(forward?t2:CATransform3DIdentity)];
    animation2.beginTime = animation.duration;
    animation2.duration = animation.duration;
    animation2.fillMode = kCAFillModeForwards;
    animation2.removedOnCompletion = NO;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.duration = animation.duration*2;
    group.animations = [NSArray arrayWithObjects:animation,animation2, nil];
    return group;
}

- (UIImageView *)addScreenshowInView:(UIView *)screenshotContainer {
    UIView *target = [self parentTarget];
    
    screenshotContainer.hidden = YES;
    UIGraphicsBeginImageContextWithOptions(target.bounds.size, YES, [[UIScreen mainScreen] scale]);
    
    if ([target respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [target drawViewHierarchyInRect:target.bounds afterScreenUpdates:YES];
    } else {
        [target.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    screenshotContainer.hidden = NO;
    
    UIImageView *screenshot = (UIImageView *)[screenshotContainer viewWithTag:PTPopViewScreenshotTag];
    if (screenshot) {
        screenshot.image = image;
    }else {
        screenshot = [[UIImageView alloc]initWithImage:image];
        screenshot.tag = PTPopViewScreenshotTag;
        [screenshotContainer addSubview:screenshot];
    }
    return screenshot;
}

@end
