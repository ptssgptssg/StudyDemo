//
//  PTDisplayLayer.h
//  PTKit
//
//  Created by 彭腾 on 16/3/31.
//  Copyright © 2016年 PT. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface PTDisplayLayer : CALayer

@property (nonatomic, assign) BOOL displaysAsynchronously;

@end

@protocol PTDisplayLayerDelegate <NSObject>

@optional

- (void)displayAsyncLayer:(PTDisplayLayer *)asyncLayer asynchronously:(BOOL)asynchronously;

@end