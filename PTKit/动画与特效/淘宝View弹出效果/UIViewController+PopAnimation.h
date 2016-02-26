//
//  UIViewController+PopAnimation.h
//  PTKit
//
//  Created by 彭腾 on 16/2/24.
//  Copyright © 2016年 PT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PTTransitionCompletionBlock)(void);

extern const struct PTPopViewOptionKeys {
    __unsafe_unretained NSString *backgroundView;
}PTPopViewOptionKeys;

@interface UIViewController (PopAnimation)

- (void)presentPopViewController:(UIViewController *)vc
                     withOptions:(NSDictionary *)options
                      completion:(PTTransitionCompletionBlock)completion
                     dimissBlock:(PTTransitionCompletionBlock)dismissBlock;
- (void)presentPopView:(UIView*)view
          withOptions:(NSDictionary*)options
           completion:(PTTransitionCompletionBlock)completion;

- (void)presentPopView:(UIView *)view withOptions:(NSDictionary *)options;
- (void)presentPopViewController:(UIViewController *)vc withOptions:(NSDictionary *)options;

@end
