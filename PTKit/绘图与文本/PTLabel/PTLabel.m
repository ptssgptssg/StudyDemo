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

- (void)initLabel {
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.contentMode = UIViewContentModeRedraw;
    _numberOfLines = 1;
    _sourceText = [NSMutableAttributedString new];
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

- (void)drawRect:(CGRect)rect {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
