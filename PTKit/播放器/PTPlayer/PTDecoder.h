//
//  PTDecoder.h
//  PTKit
//
//  Created by 彭腾 on 16/9/6.
//  Copyright © 2016年 PT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSUInteger, PTMovieFrameType) {
    PTMovieFrameTypeAudio,
    PTMovieFrameTypeVideo,
};

typedef NS_ENUM(NSUInteger, PTMovieError) {
    PTMovieErrorNone,
    PTMovieErrorOpenFile,
    PTMovieErrorStreamNotFound,
    PTMovieErrorStreamInfoNotFound,
    PTMovieErrorCodecNotFound,
    PTMovieErrorOpenCodec,
    PTMovieErrorAllocateFrame,
    PTMovieErrorDecodeVideo,
};

@interface PTMovieFrame : NSObject
@property (readonly, nonatomic) PTMovieFrameType type;
@property (readonly, nonatomic) CGFloat position;
@property (readonly, nonatomic) CGFloat duration;
@end

@interface PTVideoFrame : PTMovieFrame
@property (readonly, nonatomic) NSUInteger width;
@property (readonly, nonatomic) NSUInteger height;
@end

@interface PTVideoFrameYUV : PTVideoFrame
@property (readonly, nonatomic, strong) NSData *bytesY;
@property (readonly, nonatomic, strong) NSData *bytesU;
@property (readonly, nonatomic, strong) NSData *bytesV;
@end

@interface PTDecoder : NSObject

@property (readonly, nonatomic) NSUInteger frameWidth;
@property (readonly, nonatomic) NSUInteger frameHeight;
@property (readonly, nonatomic) BOOL isNetwork;

- (BOOL)openInput:(NSString *)path;

- (BOOL)openFile:(NSString *)path;

- (NSArray *)decodeFrames;

@end
