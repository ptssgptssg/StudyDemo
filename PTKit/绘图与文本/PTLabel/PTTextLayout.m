//
//  PTTextLayout.m
//  PTKit
//
//  Created by 彭腾 on 16/3/25.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "PTTextLayout.h"

@interface PTTextLayout ()

@end

@implementation PTTextLayout

+ (PTTextLayout *)layoutWithSize:(CGSize)size text:(NSAttributedString *)text {
    return [self layoutWithSize:size text:text range:NSMakeRange(0, [text length])];
}

+ (PTTextLayout *)layoutWithSize:(CGSize)size text:(NSAttributedString *)text range:(NSRange)range {
    CTFramesetterRef framesetter = nil;
    CTFrameRef frameRef = nil;
    CGPathRef cgPathRef = nil;
    
    text = text.mutableCopy;
    if (!text) {
        return nil;
    }
    
    framesetter = CTFramesetterCreateWithAttributedString((CFTypeRef)text);
    CGRect rect = (CGRect) {CGPointZero, size};
    cgPathRef = CGPathCreateWithRect(rect, NULL);
    frameRef = CTFramesetterCreateFrame(framesetter, CFRangeFromNSRange(range), cgPathRef, NULL);
    
    return nil;
}

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

static inline CFRange CFRangeFromNSRange(NSRange range) {
    return CFRangeMake(range.location, range.length);
}

@end
