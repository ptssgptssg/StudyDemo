//
//  PTTextLayout.m
//  PTKit
//
//  Created by 彭腾 on 16/3/25.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "PTTextLayout.h"

@implementation PTTextLayout

static void PTTextDrawText(PTTextLayout *layout, CGContextRef context, CGSize size, CGPoint point) {
    CGContextSaveGState(context); {
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextSetShadow(context, CGSizeZero, 0);
        
    } CGContextRestoreGState(context);
}

- (void)drawInContext:(CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
                 view:(UIView *)view
                layer:(CALayer *)layer {
    @autoreleasepool {
        PTTextDrawText(self, context, size, point);
    }
}

@end
