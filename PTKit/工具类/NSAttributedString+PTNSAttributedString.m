//
//  NSAttributedString+PTNSAttributedString.m
//  PTKit
//
//  Created by 彭腾 on 16/3/21.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "NSAttributedString+PTNSAttributedString.h"
#import <CoreText/CoreText.h>

@implementation NSAttributedString (PTNSAttributedString)

+ (CGFloat)heightForHtmlString:(NSAttributedString *)string width:(CGFloat)width {
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
    CGSize restrictSize = CGSizeMake(width, CGFLOAT_MAX);
    CGSize coretextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, 0), nil, restrictSize, nil);
    return coretextSize.height;
}

+ (NSAttributedString *)stringForHtmlString:(NSString *)string {
    NSAttributedString *attributedString = [[NSAttributedString alloc]initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    return attributedString;
}

@end
