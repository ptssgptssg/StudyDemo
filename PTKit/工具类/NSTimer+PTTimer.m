//
//  NSTimer+PTTimer.m
//  PTKit
//
//  Created by 彭腾 on 16/2/29.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "NSTimer+PTTimer.h"

@implementation NSTimer (PTTimer)

+ (NSTimer *)pt_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void (^)())block repeats:(BOOL)repeats {
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(pt_blockInvoke:) userInfo:[block copy] repeats:YES];
}

+ (void)pt_blockInvoke:(NSTimer *)timer {
    void (^block)() = timer.userInfo;
    if (block) {
        block();
    }
}

@end
