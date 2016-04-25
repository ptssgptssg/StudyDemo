//
//  PTTextLayout.m
//  PTKit
//
//  Created by 彭腾 on 16/3/25.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "PTTextLayout.h"

@interface PTTextLayout ()

@property (nonatomic, readwrite) NSAttributedString *text;
@property (nonatomic, readwrite) CTFramesetterRef frameSetter;
@property (nonatomic, readwrite) CTFrameRef frame;
@property (nonatomic, readwrite) NSArray *lines;
@property (nonatomic, readwrite) NSUInteger rowCount;
@property (nonatomic, readwrite) NSRange visibleRange;
@property (nonatomic, readwrite) CGRect textBoundingRect;
@property (nonatomic, readwrite) CGSize textBoundingSize;

@end

@implementation PTTextLayout

- (void)setFrameSetter:(CTFramesetterRef)frameSetter {
    if (_frameSetter != frameSetter) {
        if (_frameSetter != nil) {
            CFRelease(_frameSetter);
        }
    }
    CFRetain(frameSetter);
    _frameSetter = frameSetter;
}

- (void)setFrame:(CTFrameRef)frame {
    if (_frame != frame) {
        if (_frame != nil) {
            CFRelease(_frame);
        }
    }
    CFRetain(frame);
    _frame = frame;
}

- (void)dealloc {
    if (_frameSetter) {
        CFRelease(_frameSetter);
    }
    if (_frame) {
        CFRelease(_frame);
    }
}

+ (PTTextLayout *)layoutWithSize:(CGSize)size text:(NSAttributedString *)text {
    return [self layoutWithSize:size text:text range:NSMakeRange(0, [text length])];
}

+ (PTTextLayout *)layoutWithSize:(CGSize)size text:(NSAttributedString *)text range:(NSRange)range {
    PTTextLayout *layout = nil;
    CTFramesetterRef framesetter = nil;
    CTFrameRef frameRef = nil;
    CGPathRef cgPathRef = nil;
    CFArrayRef ctLines = nil;
    NSMutableArray *lines = nil;
    NSUInteger lineCount = 0;
    CGPoint *lineOrigins = nil;
    NSRange visibleRange;
    CGRect cgPathBox = {0};
    NSUInteger maximumNumberOfRows = 0;

    text = text.mutableCopy;
    if (!text) {
        return nil;
    }
    
    layout = [[PTTextLayout alloc]init];
    layout.text = text;
    
    framesetter = CTFramesetterCreateWithAttributedString((CFTypeRef)text);
    CGRect rect = (CGRect) {CGPointZero, size};
    cgPathBox = rect;
    cgPathRef = CGPathCreateWithRect(rect, NULL);
    frameRef = CTFramesetterCreateFrame(framesetter, CFRangeFromNSRange(range), cgPathRef, NULL);
    
    lines = [NSMutableArray array];
    ctLines = CTFrameGetLines(frameRef);
    lineCount = CFArrayGetCount(ctLines);
    if (lineCount > 0) {
        lineOrigins = malloc(lineCount * sizeof(CGPoint));
        CTFrameGetLineOrigins(frameRef, CFRangeMake(0, lineCount), lineOrigins);
    }
    
    CGRect textBoundingRect = CGRectZero;
    CGSize textBoundingSize = CGSizeZero;
    NSInteger rowIdx = -1;
    NSUInteger rowCount = 0;
    CGRect lastRect = CGRectMake(0, -FLT_MAX, 0, 0);
    CGPoint lastPosition = CGPointMake(0, -FLT_MAX);
    
    NSUInteger lineCurrentIdx = 0;
    for (NSUInteger i = 0; i < lineCount; i++) {
        CTLineRef ctLine = CFArrayGetValueAtIndex(ctLines, i);
        CFArrayRef ctRuns = CTLineGetGlyphRuns(ctLine);
        if (!ctRuns || CFArrayGetCount(ctRuns) == 0) {
            continue;
        }

        CGPoint ctLineOrigin = lineOrigins[i];
        
        CGPoint position;
        position.x = cgPathBox.origin.x + ctLineOrigin.x;
        position.y = cgPathBox.size.height + cgPathBox.origin.y - ctLineOrigin.y;
        
        PTTextLine *line = [PTTextLine lineWithCTLine:ctLine position:position];
        CGRect rect = line.bounds;
        BOOL newRow = YES;
        
        if (newRow) {
            rowIdx++;
            lastRect = rect;
            lastPosition = position;
            
            line.index = lineCurrentIdx;
            line.row = rowIdx;
            [lines addObject:line];
            rowCount = rowIdx + 1;
            lineCurrentIdx++;
        }
        
        if (i == 0) {
            textBoundingRect = rect;
        }else {
            if (maximumNumberOfRows == 0 || rowIdx < maximumNumberOfRows) {
                textBoundingRect = CGRectUnion(textBoundingRect, rect);
            }
        }
    }
    
    {
        CGRect rect = textBoundingRect;
        rect = CGRectStandardize(rect);
        CGSize size = rect.size;
        size.width += rect.origin.x;
        size.height += rect.origin.y;
        if (size.width < 0) {
            size.width = 0;
        }
        if (size.height < 0) {
            size.height = 0;
        }
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        textBoundingSize = size;
    }
    
    visibleRange = NSRangeFromCFRange(CTFrameGetVisibleStringRange(frameRef));
    
    layout.frameSetter = framesetter;
    layout.frame = frameRef;
    layout.lines = lines;
    layout.rowCount = rowCount;
    layout.textBoundingRect = textBoundingRect;
    layout.textBoundingSize = textBoundingSize;
    layout.visibleRange = visibleRange;
    
    return layout;
}

static void PTTextDrawText(PTTextLayout *layout, CGContextRef context, CGSize size, CGPoint point) {
    CGContextSaveGState(context); {
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextSetShadow(context, CGSizeZero, 0);
        
        NSArray *lines = layout.lines;
        for (NSUInteger i = 0; i < lines.count; i++) {
            PTTextLine *line = lines[i];
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextSetTextPosition(context, line.position.x, size.height - line.position.y);
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            for (NSUInteger i = 0; i < CFArrayGetCount(runs); i++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, i);
                CTRunDraw(run, context, CFRangeMake(0, 0));
            }
        }
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

static inline NSRange NSRangeFromCFRange(CFRange range) {
    return NSMakeRange(range.location, range.length);
}

@end
