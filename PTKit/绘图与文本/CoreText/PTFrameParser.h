//
//  PTFrameParser.h
//  PTKit
//
//  Created by 彭腾 on 16/3/8.
//  Copyright © 2016年 PT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTextData.h"
#import "PTFrameParserConfig.h"

@interface PTFrameParser : NSObject

+ (CoreTextData *)parseContent:(NSString *)content config:(PTFrameParserConfig *)config;

@end
