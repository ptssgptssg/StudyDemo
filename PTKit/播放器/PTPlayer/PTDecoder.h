//
//  PTDecoder.h
//  PTKit
//
//  Created by 彭腾 on 16/9/6.
//  Copyright © 2016年 PT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTDecoder : NSObject

@property (readonly, nonatomic) BOOL isNetwork;

- (BOOL)openFile:(NSString *)path
           error:(NSError **)perror;

@end
