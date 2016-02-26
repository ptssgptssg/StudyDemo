//
//  TaoBaoPopViewController.m
//  PTKit
//
//  Created by 彭腾 on 16/2/24.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "TaoBaoPopViewController.h"
#import "UIViewController+PopAnimation.h"

@interface TaoBaoPopViewController ()

@end

@implementation TaoBaoPopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [imageView setImage:[UIImage imageNamed:@"bg"]];
    [self.view addSubview:imageView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 100, 100);
    [button setTitle:@"点我" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)click {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 240)];
    view.backgroundColor = [UIColor redColor];
    UIImageView *bgimgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_01"]];
    [self presentPopView:view withOptions:@{PTPopViewOptionKeys.backgroundView:bgimgv}];
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
