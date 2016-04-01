//
//  PTDisplayLayer.m
//  PTKit
//
//  Created by 彭腾 on 16/3/31.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "PTDisplayLayer.h"

@interface PTDisplayLayer () {
    id<PTDisplayLayerDelegate> __weak _asyncDelegate;
}
@end

@implementation PTDisplayLayer

+ (id)defaultValueForKey:(NSString *)key {
    if ([key isEqualToString:@"displaysAsynchronously"]) {
        return @(YES);
    }else {
        return [super defaultValueForKey:key];
    }
}

- (void)display {
    [self display:self.displaysAsynchronously];
}

- (void)display:(BOOL)asynchronously {
    [_asyncDelegate displayAsyncLayer:self asynchronously:asynchronously];
}

@end
