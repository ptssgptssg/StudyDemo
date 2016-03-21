//
//  NSAttributedString+PTNSAttributedString.h
//  PTKit
//
//  Created by 彭腾 on 16/3/21.
//  Copyright © 2016年 PT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString (PTNSAttributedString)

+ (CGFloat)heightForHtmlString:(NSAttributedString *)string width:(CGFloat)width;

+ (NSAttributedString *)stringForHtmlString:(NSString *)string;

@end
