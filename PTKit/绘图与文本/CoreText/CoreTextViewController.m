//
//  CoreTextViewController.m
//  PTKit
//
//  Created by 彭腾 on 16/3/7.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "CoreTextViewController.h"
#import "PTDisplayView.h"
#import "PTKit.h"
#import "CoreTextData.h"
#import "PTFrameParserConfig.h"
#import "PTFrameParser.h"
#import "PTLabel.h"

@interface CoreTextViewController ()

@end

@implementation CoreTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    PTDisplayView *view = [[PTDisplayView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
//    view.center = CGPointMake(self.view.width/2, self.view.height/2);
//    [self.view addSubview:view];
//    
//    PTFrameParserConfig *config = [[PTFrameParserConfig alloc]init];
//    config.textColor = [UIColor whiteColor];
//    config.width = 100;
//    
//    CoreTextData *data = [PTFrameParser parseContent:@"123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123" config:config];
//    view.data = data;
//    view.height = data.height;
    PTLabel *label = [PTLabel new];
    label.text = @"1111";
    [self.view addSubview:label];
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
