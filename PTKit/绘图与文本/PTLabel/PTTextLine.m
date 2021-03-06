//
//  PTTextLine.m
//  PTKit
//
//  Created by 彭腾 on 16/4/21.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "PTTextLine.h"

@interface PTTextLine () {
    CGFloat _firstGlyphPos;
}
@end

@implementation PTTextLine

+ (instancetype)lineWithCTLine:(CTLineRef)CTLine position:(CGPoint)position {
    if (!CTLine) {
        return nil;
    }
    PTTextLine *line = [self new];
    line.position = position;
    [line setCTLine:CTLine];
    return line;
}

- (void)setCTLine:(CTLineRef)CTLine {
    if (_CTLine != CTLine) {
        if (CTLine) {
            CFRetain(CTLine);
        }
        if (_CTLine) {
            CFRelease(_CTLine);
        }
        _CTLine = CTLine;
        if (_CTLine) {
            _lineWidth = CTLineGetTypographicBounds(_CTLine, &_ascent, &_descent, &_leading);
            CFRange range = CTLineGetStringRange(_CTLine);
            _range = NSMakeRange(range.location, range.length);
            if (CTLineGetGlyphCount(_CTLine) > 0) {
                CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
                CTRunRef run = CFArrayGetValueAtIndex(runs, 0);
                CGPoint pos;
                CTRunGetPositions(run, CFRangeMake(0, 1), &pos);
                _firstGlyphPos = pos.x;
            }else {
                _firstGlyphPos = 0;
            }
            //获取一行未尾字符后空格的像素长度
            _trailingWhitespaceWidth = CTLineGetTrailingWhitespaceWidth(_CTLine);
        }else {
            _lineWidth = _ascent = _descent = _leading = _firstGlyphPos = _trailingWhitespaceWidth = 0;
            _range = NSMakeRange(0, 0);
        }
        [self reloadBounds];
    }
}

- (void)reloadBounds {
    _bounds = CGRectMake(_position.x, _position.y - _ascent, _lineWidth, _ascent + _descent);
    _bounds.origin.x += _firstGlyphPos;
    
    if (!_CTLine) return;
    CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
    NSUInteger runCount = CFArrayGetCount(runs);
    if (runCount == 0) return;
}

- (CGSize)size {
    return _bounds.size;
}

- (CGFloat)width {
    return CGRectGetWidth(_bounds);
}

- (CGFloat)height {
    return CGRectGetHeight(_bounds);
}

- (CGFloat)top {
    return CGRectGetMinY(_bounds);
}

- (CGFloat)bottom {
    return CGRectGetMaxY(_bounds);
}

- (CGFloat)left {
    return CGRectGetMinX(_bounds);
}

- (CGFloat)right {
    return CGRectGetMaxX(_bounds);
}

@end
