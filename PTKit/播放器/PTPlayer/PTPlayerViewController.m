//
//  PTPlayerViewController.m
//  PTKit
//
//  Created by 彭腾 on 16/9/7.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "PTPlayerViewController.h"
#import "PTDecoder.h"

@interface PTPlayerViewController () {
    dispatch_queue_t queue;
}
@end

@implementation PTPlayerViewController

- (void)play {
    
}

- (void)pause {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PTDecoder *decoder = [[PTDecoder alloc]init];
    queue = dispatch_queue_create("com.decoder.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        
    });
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
