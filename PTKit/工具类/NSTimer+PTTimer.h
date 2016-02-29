//
//  NSTimer+PTTimer.h
//  PTKit
//
//  Created by 彭腾 on 16/2/29.
//  Copyright © 2016年 PT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (PTTimer)

+ (NSTimer *)pt_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void(^)())block
                                       repeats:(BOOL)repeats;

@end
