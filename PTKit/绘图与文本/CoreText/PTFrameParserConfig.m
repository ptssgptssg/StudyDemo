//
//  PTFrameParserConfig.m
//  PTKit
//
//  Created by 彭腾 on 16/3/8.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "PTFrameParserConfig.h"

@implementation PTFrameParserConfig

- (id)init {
    self = [super init];
    if (self) {
        _width = 100.0f;
        _fontSize = 16.0f;
        _linsSpace = 8.0f;
        _textColor = [UIColor colorWithRed:108/255.0 green:108/255.0 blue:108/255.0 alpha:1.0];
    }
    return self;
}

@end
