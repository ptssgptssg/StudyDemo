//
//  WeiboPopViewController.m
//  PTKit
//
//  Created by 彭腾 on 16/3/1.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "WeiboPopViewController.h"
#import "PTWeiboMenuView.h"

@interface WeiboPopViewController ()

@end

@implementation WeiboPopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(200, 200, 200, 200);
    [button setTitle:@"点击" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)click {
    PTWeiboMenuView *menuView = [[PTWeiboMenuView alloc]init];
    
    [menuView addItemWithTitle:@"照相机" andIcon:[UIImage imageNamed:@"tabbar_compose_camera"] andSelectedBlock:^{
    }];
    [menuView addItemWithTitle:@"照相机" andIcon:[UIImage imageNamed:@"tabbar_compose_idea"] andSelectedBlock:^{
    }];
    [menuView addItemWithTitle:@"照相机" andIcon:[UIImage imageNamed:@"tabbar_compose_lbs"]
        andSelectedBlock:^{
    }];
    [menuView addItemWithTitle:@"照相机" andIcon:[UIImage imageNamed:@"tabbar_compose_more"] andSelectedBlock:^{
    }];
    [menuView addItemWithTitle:@"照相机" andIcon:[UIImage imageNamed:@"tabbar_compose_photo"] andSelectedBlock:^{
    }];
    [menuView addItemWithTitle:@"照相机" andIcon:[UIImage imageNamed:@"tabbar_compose_review"] andSelectedBlock:^{
    }];
    
    [menuView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
