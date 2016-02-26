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

-(void)presentPopView:(UIView*)view
          withOptions:(NSDictionary*)options
           completion:(PTTransitionCompletionBlock)completion;

- (void)presentPopView:(UIView *)view withOptions:(NSDictionary *)options;

@end
