//
//  PTTextLayout.h
//  PTKit
//
//  Created by 彭腾 on 16/3/25.
//  Copyright © 2016年 PT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>



@interface PTTextLayout : NSObject

+ (PTTextLayout *)layoutWithSize:(CGSize)size text:(NSAttributedString *)text;

+ (PTTextLayout *)layoutWithSize:(CGSize)size text:(NSAttributedString *)text range:(NSRange)range;

- (void)drawInContext:(CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
                 view:(UIView *)view
                layer:(CALayer *)layer;

@end
