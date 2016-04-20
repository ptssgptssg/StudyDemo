//
//  PTLabel.m
//  PTKit
//
//  Created by 彭腾 on 16/3/25.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "PTLabel.h"
#import "PTTextLayout.h"
#import "PTDisplayLayer.h"

@interface PTLabel ()<PTDisplayLayerDelegate> {
    NSMutableAttributedString *_sourceText;
    PTTextLayout *_sourceLayout;
}

@end

@implementation PTLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initLabel];
    }
    return self;
}

+ (Class)layerClass {
    return [PTDisplayLayer class];
}

- (void)initLabel {
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.contentMode = UIViewContentModeRedraw;
    _numberOfLines = 1;
    _sourceText = [NSMutableAttributedString new];
    [self.layer setNeedsDisplay];
}

- (void)setText:(NSString *)text {
    _text = text.copy;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _sourceText = attributedText.mutableCopy;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    _numberOfLines = numberOfLines;
}

- (void)displayAsyncLayer:(PTDisplayLayer *)asyncLayer asynchronously:(BOOL)asynchronously {
    __block PTTextLayout *layout = [[PTTextLayout alloc]init];
    CGPoint point = CGPointZero;
    UIGraphicsBeginImageContextWithOptions(self.layer.bounds.size, self.layer.opaque, self.layer.contentsScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [layout drawInContext:context size:self.layer.bounds.size point:point view:nil layer:nil];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.layer.contents = (__bridge id)image.CGImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
