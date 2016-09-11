//
//  PTDecoder.m
//  PTKit
//
//  Created by 彭腾 on 16/9/6.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "PTDecoder.h"
#import <libavformat/avformat.h>
#import <libavcodec/avcodec.h>
#import <libswscale/swscale.h>

static BOOL isNetworkPath(NSString *path) {
    NSRange range = [path rangeOfString:@":"];
    if (range.location == NSNotFound) {
        return NO;
    }
    NSString *scheme = [path substringToIndex:range.location];
    if ([scheme isEqualToString:@"file"]) {
        return NO;
    }
    return YES;
}

static NSArray *collectStreams(AVFormatContext *formatCtx, enum AVMediaType codecType) {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < formatCtx->nb_streams; i++) {
        if (codecType == formatCtx->streams[i]->codec->codec_type) {
            [array addObject:[NSNumber numberWithInteger:i]];
        }
    }
    return [array copy];
}

static NSData *copyFrameData(UInt8 *src, int linesize, int width, int height) {
    width = MIN(linesize, width);
    NSMutableData *md = [NSMutableData dataWithLength:width * height];
    Byte *dst = md.mutableBytes;
    for (NSUInteger i = 0; i < height; i++) {
        memcpy(dst, src, width);
        dst += width;
        src += linesize;
    }
    return md;
}

@interface PTMovieFrame()
@property (readwrite, nonatomic) CGFloat position;
@property (readwrite, nonatomic) CGFloat duration;
@end

@implementation PTMovieFrame
@end

@interface PTVideoFrame()
@property (readwrite, nonatomic) NSUInteger width;
@property (readwrite, nonatomic) NSUInteger height;
@end

@implementation PTVideoFrame
@end

@interface PTVideoFrameYUV()
@property (readwrite, nonatomic, strong) NSData *bytesY;
@property (readwrite, nonatomic, strong) NSData *bytesU;
@property (readwrite, nonatomic, strong) NSData *bytesV;
@end

@implementation PTVideoFrameYUV
@end

@interface PTDecoder () {
    NSInteger videostream;
    NSArray *videostreams;
    AVFrame *videoFrame;
    AVCodecContext *codecCtx;
}
@end

@implementation PTDecoder

- (BOOL)openFile:(NSString *)path
           error:(NSError *__autoreleasing *)perror {
    _isNetwork = isNetworkPath(path);
    if (_isNetwork) {
        avformat_network_init();
    }
    
    AVFormatContext *formatCtx = avformat_alloc_context();
    
    if (avformat_open_input(&formatCtx, [path cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL) != 0) {
        if (formatCtx) {
            avformat_free_context(formatCtx);
        }
        NSLog(@"Couldn't open input stream.\n");
        return NO;
    }
    
    if (avformat_find_stream_info(formatCtx, NULL) < 0) {
        avformat_close_input(&formatCtx);
        printf("Couldn't find stream information.\n");
        return NO;
    }
    
    videostream = -1;
    videostreams = collectStreams(formatCtx, AVMEDIA_TYPE_VIDEO);
    
    for (NSNumber *number in videostreams) {
        
        NSUInteger iStream = number.integerValue;
        if ((formatCtx->streams[iStream]->disposition & AV_DISPOSITION_ATTACHED_PIC) == 0) {
            
            codecCtx = formatCtx->streams[iStream]->codec;
            AVCodec *codec = avcodec_find_decoder(codecCtx->codec_id);
            
            if (!codec) {
                NSLog(@"Codec not found.");
                return NO;
            }
            
            if (avcodec_open2(codecCtx, codec, NULL) < 0) {
                NSLog(@"Counld not open codec.");
                return NO;
            }
            
            videoFrame = av_frame_alloc();
            if (!videoFrame) {
                avcodec_close(codecCtx);
                return NO;
            }
        }
    }
    
    AVPacket packet;
    
    NSMutableArray *result = [NSMutableArray array];
    
    while (av_read_frame(formatCtx, &packet) > 0) {
        if (packet.stream_index == videostream) {
            int gotframe = 0;
            int ret = avcodec_decode_video2(codecCtx, videoFrame, &gotframe, &packet);
            if (ret < 0) {
                NSLog(@"decode video error");
                break;
            }
            PTVideoFrame *frame;
            PTVideoFrameYUV *yuvFrame = [[PTVideoFrameYUV alloc]init];
            yuvFrame.bytesY = copyFrameData(videoFrame->data[0], videoFrame->linesize[0], codecCtx->width, codecCtx->height);
            yuvFrame.bytesU = copyFrameData(videoFrame->data[1], videoFrame->linesize[1], codecCtx->width/2, codecCtx->height/2);
            yuvFrame.bytesV = copyFrameData(videoFrame->data[2], videoFrame->linesize[2], codecCtx->width/2, codecCtx->height/2);
            frame = yuvFrame;
            if (frame) {
                [result addObject:frame];
            }
        }
    }
    
    return YES;
}

+ (void)initialize {
    av_register_all();
}

@end
