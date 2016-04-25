//
//  PTTextLine.h
//  PTKit
//
//  Created by 彭腾 on 16/4/21.
//  Copyright © 2016年 PT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface PTTextLine : NSObject

+ (instancetype)lineWithCTLine:(CTLineRef)CTLine position:(CGPoint)position;

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSUInteger row;

@property (nonatomic, readonly) CTLineRef CTLine;
@property (nonatomic, readonly) NSRange range;     

@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) CGFloat top;
@property (nonatomic, readonly) CGFloat bottom;
@property (nonatomic, readonly) CGFloat left;
@property (nonatomic, readonly) CGFloat right;

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, readonly) CGFloat ascent;     
@property (nonatomic, readonly) CGFloat descent;
@property (nonatomic, readonly) CGFloat leading;
@property (nonatomic, readonly) CGFloat lineWidth;
@property (nonatomic, readonly) CGFloat trailingWhitespaceWidth;

@end
