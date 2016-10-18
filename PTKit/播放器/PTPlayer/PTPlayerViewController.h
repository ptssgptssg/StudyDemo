//
//  PTPlayerViewController.h
//  PTKit
//
//  Created by 彭腾 on 16/9/7.
//  Copyright © 2016年 PT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTPlayerViewController : UIViewController

+ (id)movieViewControllerWithContentPath:(NSString *)path;

- (void)play;

- (void)pause;

@end
